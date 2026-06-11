//
//  iPhoneBLEPeripheralManager.swift
//  Mayoty
//
//  Created by sun on 6/7/26.
//

import Foundation
import CoreBluetooth

enum BLEPeripheralEvent {
    case bluetoothStateChanged(String, log: String?)
    case advertisingChanged(Bool, log: String)
    case watchConnected(id: UUID)
    case watchDisconnected(id: UUID)
    case answerReceived(id: UUID, answer: BLEAnswer)
    case log(String)
}

final class iPhoneBLEPeripheralManager: NSObject, CBPeripheralManagerDelegate {

    private var peripheralManager: CBPeripheralManager?

    /// Watch → iPhone
    private var answerCharacteristic: CBMutableCharacteristic?

    /// iPhone → Watch
    private var commandCharacteristic: CBMutableCharacteristic?

    /// command characteristic을 구독 중인 Watch들 (central id → CBCentral)
    /// 특정 Watch에만 notify를 보내려면 CBCentral 인스턴스가 필요함
    private var subscribedCentrals: [UUID: CBCentral] = [:]

    /// 서비스가 이미 등록되어 중복 등록 방지 (전원 사이클 시 리셋)
    private var isServiceAdded: Bool = false

    /// updateValue 내부 큐가 가득 찼을 때 재전송 대기 중인 명령
    /// peripheralManagerIsReady 콜백에서 순서대로 재전송
    private let commandQueue = BLECommandQueue()

    let events: AsyncStream<BLEPeripheralEvent>
    private let continuation: AsyncStream<BLEPeripheralEvent>.Continuation

    override init() {
        let stream = AsyncStream.makeStream(of: BLEPeripheralEvent.self)

        self.events = stream.stream
        self.continuation = stream.continuation

        super.init()
    }

#if DEBUG
    /// 시뮬레이터 데모용 TCP 브리지 (-blebridge 런치 인자)
    private var bridge: BLEBridgeServer?

    private var isBridgeMode: Bool {
        ProcessInfo.processInfo.arguments.contains("-blebridge")
    }
#endif

    /// CBPeripheralManager 생성 — 첫 화면 표시 시점에 호출
    /// (@main 부트스트랩 중 생성하면 시스템 데몬 연결 시점이 너무 일러질 수 있음)
    func activate() {
#if DEBUG
        if isBridgeMode {
            startBridge()
            return
        }
#endif

        guard peripheralManager == nil else { return }

        GameLogger.bluetooth("PeripheralManager 활성화")

        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
    }

#if DEBUG
    private func startBridge() {
        guard bridge == nil else { return }

        let bridge = BLEBridgeServer()

        bridge.onWatchConnected = { [weak self] id in
            self?.continuation.yield(.watchConnected(id: id))
        }

        bridge.onWatchDisconnected = { [weak self] id in
            self?.continuation.yield(.watchDisconnected(id: id))
        }

        bridge.onAnswer = { [weak self] id, answer in
            self?.continuation.yield(.answerReceived(id: id, answer: answer))
        }

        bridge.start()
        self.bridge = bridge

        continuation.yield(
            .bluetoothStateChanged("Bridge", log: "시뮬레이터 TCP 브리지 모드")
        )
    }
#endif

    // MARK: - Bluetooth State

    func peripheralManagerDidUpdateState(
        _ peripheral: CBPeripheralManager
    ) {
        GameLogger.bluetooth("PeripheralManager 상태: \(peripheral.state.rawValue)")

        switch peripheral.state {
        case .poweredOn:
            continuation.yield(
                .bluetoothStateChanged(
                    "Powered On",
                    log: "블루투스가 활성화"
                )
            )

            setupService()
            startAdvertising()

        case .poweredOff:
            GameLogger.bluetooth("블루투스 비활성화")
            resetSessionState()

            continuation.yield(
                .bluetoothStateChanged(
                    "Powered Off",
                    log: "블루투스가 비활성화"
                )
            )

        case .unauthorized:
            GameLogger.bluetooth("블루투스 권한 없음")
            resetSessionState()

            continuation.yield(
                .bluetoothStateChanged(
                    "Unauthorized",
                    log: "블루투스 권한 없음"
                )
            )

        case .unsupported:
            GameLogger.bluetooth("이 기기는 블루투스를 지원하지 않음")

            continuation.yield(
                .bluetoothStateChanged(
                    "Unsupported",
                    log: "이 기기는 블루투스를 지원하지 않음"
                )
            )

        case .resetting:
            GameLogger.bluetooth("블루투스 재설정 중")
            resetSessionState()

            continuation.yield(
                .bluetoothStateChanged(
                    "Resetting",
                    log: nil
                )
            )

        case .unknown:
            continuation.yield(
                .bluetoothStateChanged(
                    "Unknown",
                    log: nil
                )
            )

        @unknown default:
            continuation.yield(
                .bluetoothStateChanged(
                    "Unknown Default",
                    log: nil
                )
            )
        }
    }

    /// 전원 off/리셋 시 GATT DB와 구독이 시스템에 의해 모두 제거되므로
    /// 다시 poweredOn이 됐을 때 서비스를 재등록할 수 있도록 상태를 초기화
    private func resetSessionState() {
        isServiceAdded = false
        commandQueue.removeAll()

        for id in subscribedCentrals.keys {
            continuation.yield(.watchDisconnected(id: id))
        }
        subscribedCentrals.removeAll()
    }

    // MARK: - Service

    /// BLE Service와 Characteristic을 등록 (poweredOn마다 1회)
    private func setupService() {
        guard let peripheralManager else { return }
        guard !isServiceAdded else {
            GameLogger.bluetooth("Service already added — skip")
            continuation.yield(.log("Service already added — skip"))
            return
        }

        let answerCharacteristic = CBMutableCharacteristic(
            type: BLEUUID.answer,
            properties: [.write, .writeWithoutResponse],
            value: nil,
            permissions: [.writeable]
        )

        let commandCharacteristic = CBMutableCharacteristic(
            type: BLEUUID.command,
            properties: [.notify, .read],
            value: nil,
            permissions: [.readable]
        )

        self.answerCharacteristic = answerCharacteristic
        self.commandCharacteristic = commandCharacteristic

        let service = CBMutableService(
            type: BLEUUID.service,
            primary: true
        )

        service.characteristics = [
            answerCharacteristic,
            commandCharacteristic
        ]

        // 이전 세션의 잔여 등록을 정리한 뒤 등록 (검증된 기존 동작)
        peripheralManager.removeAllServices()
        peripheralManager.add(service)
        isServiceAdded = true

        GameLogger.bluetooth("Service 등록 요청")
        continuation.yield(
            .log("Service added")
        )
    }

    /// Service 등록 결과 — 실패 시 원인 파악용
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didAdd service: CBService,
        error: Error?
    ) {
        if let error {
            GameLogger.bluetooth("Service 등록 실패: \(error.localizedDescription)")
            continuation.yield(.log("Service add error: \(error.localizedDescription)"))
        } else {
            GameLogger.bluetooth("Service 등록 완료")
        }
    }

    // MARK: - Advertising

    /// Watch가 검색할 수 있도록 Advertising 시작
    /// 항상 광고를 유지 — 구독 수로 광고를 막으면 stale 구독이 남았을 때
    /// 새 Watch가 iPhone을 발견하지 못하게 됨
    func startAdvertising() {
        guard let peripheralManager else { return }

        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [BLEUUID.service],
            CBAdvertisementDataLocalNameKey: "Answer-iPhone"
        ])

        GameLogger.bluetooth("Advertising 시작 요청")
        continuation.yield(
            .advertisingChanged(
                true,
                log: "Advertising started"
            )
        )
    }

    /// Advertising 중지
    func stopAdvertising() {
        peripheralManager?.stopAdvertising()

        GameLogger.bluetooth("Advertising 중지")
        continuation.yield(
            .advertisingChanged(
                false,
                log: "Advertising stopped"
            )
        )
    }

    func peripheralManagerDidStartAdvertising(
        _ peripheral: CBPeripheralManager,
        error: Error?
    ) {
        if let error {
            GameLogger.bluetooth("Advertising 실패: \(error.localizedDescription)")
            continuation.yield(
                .log(
                    "Advertising error: \(error.localizedDescription)"
                )
            )
        } else {
            GameLogger.bluetooth("Advertising 성공")
            continuation.yield(
                .log("Advertising success")
            )
        }
    }

    // MARK: - Command

    /// iPhone → Watch 명령 전송
    /// - Parameter centralID: 특정 Watch에만 보낼 때 해당 central id, nil이면 전체 브로드캐스트
    func sendCommand(_ command: BLECommand, to centralID: UUID? = nil) {
#if DEBUG
        if let bridge {
            bridge.send(command.data, to: centralID)
            GameLogger.bluetooth("Command sent (bridge): \(command.kind)")
            continuation.yield(.log("Command sent: \(command.kind)"))
            return
        }
#endif

        let entry = BLECommandQueue.Entry(
            data: command.data,
            centralID: centralID,
            label: "\(command.kind)"
        )

        let sentNow = commandQueue.send(entry) { deliver($0) }

        if !sentNow {
            GameLogger.bluetooth("Command queued (BLE busy): \(entry.label)")
            continuation.yield(.log("Command queued (BLE busy): \(entry.label)"))
        }
    }

    /// 실제 notify 전송. 큐가 가득 차면 false 반환
    private func deliver(_ entry: BLECommandQueue.Entry) -> Bool {
        guard let peripheralManager, let commandCharacteristic else {
            GameLogger.bluetooth("Command dropped (BLE not ready): \(entry.label)")
            continuation.yield(.log("Command dropped (BLE not ready): \(entry.label)"))
            return true
        }

        var targets: [CBCentral]?

        if let centralID = entry.centralID {
            guard let central = subscribedCentrals[centralID] else {
                // 대상 Watch가 이미 구독 해제됨 — 폐기
                GameLogger.bluetooth("Command dropped (watch gone): \(entry.label)")
                continuation.yield(
                    .log("Command dropped (watch gone): \(entry.label) → \(centralID.uuidString.prefix(8))")
                )
                return true
            }
            targets = [central]
        }

        let success = peripheralManager.updateValue(
            entry.data,
            for: commandCharacteristic,
            onSubscribedCentrals: targets
        )

        if success {
            GameLogger.bluetooth("Command sent: \(entry.label)\(entry.centralID.map { " → \($0.uuidString.prefix(8))" } ?? "")")
            continuation.yield(.log("Command sent: \(entry.label)"))
        }

        return success
    }

    /// updateValue 큐에 자리가 생기면 대기 중인 명령을 순서대로 재전송
    func peripheralManagerIsReady(
        toUpdateSubscribers peripheral: CBPeripheralManager
    ) {
        commandQueue.flush { deliver($0) }
    }

    // MARK: - Subscription Tracking

    /// Watch가 command characteristic을 구독하기 시작 (실연결 신호)
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo characteristic: CBCharacteristic
    ) {
        guard characteristic.uuid == BLEUUID.command else { return }

        let id = central.identifier
        subscribedCentrals[id] = central

        GameLogger.bluetooth("Subscribed: \(id.uuidString.prefix(8)) (총 \(subscribedCentrals.count)대)")
        continuation.yield(
            .log("Subscribed: \(id.uuidString.prefix(8)) (\(subscribedCentrals.count))")
        )

        continuation.yield(.watchConnected(id: id))
    }

    /// Watch가 구독 해제 → 상위 레이어에 알림
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom characteristic: CBCharacteristic
    ) {
        guard characteristic.uuid == BLEUUID.command else { return }

        let id = central.identifier
        subscribedCentrals.removeValue(forKey: id)

        GameLogger.bluetooth("Unsubscribed: \(id.uuidString.prefix(8)) (총 \(subscribedCentrals.count)대)")
        continuation.yield(
            .log("Unsubscribed: \(id.uuidString.prefix(8)) (\(subscribedCentrals.count))")
        )

        continuation.yield(.watchDisconnected(id: id))
    }

    // MARK: - Receive Answer

    /// Watch가 보낸 응답을 수신
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        guard let firstRequest = requests.first else { return }

        for request in requests {
            guard request.characteristic.uuid == BLEUUID.answer else {
                peripheral.respond(
                    to: firstRequest,
                    withResult: .requestNotSupported
                )
                return
            }

            guard let data = request.value,
                  BLEAnswer(data: data) != nil
            else {
                peripheral.respond(
                    to: firstRequest,
                    withResult: .invalidAttributeValueLength
                )
                return
            }
        }

        for request in requests {
            let centralID = request.central.identifier

            continuation.yield(
                .watchConnected(id: centralID)
            )

            guard let data = request.value,
                  let answer = BLEAnswer(data: data)
            else { continue }

            GameLogger.bluetooth("Answer 수신: \(answer.kind) ← \(centralID.uuidString.prefix(8))")
            continuation.yield(
                .answerReceived(
                    id: centralID,
                    answer: answer
                )
            )
        }

        peripheral.respond(
            to: firstRequest,
            withResult: .success
        )
    }
}
