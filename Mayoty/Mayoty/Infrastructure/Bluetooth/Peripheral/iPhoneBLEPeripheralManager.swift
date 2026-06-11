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

    /// 최대 동시 구독 Watch 수 — iOS Peripheral 한계 보호용
    private let maxSubscribers: Int = 5

    private var peripheralManager: CBPeripheralManager?

    /// Watch → iPhone
    private var answerCharacteristic: CBMutableCharacteristic?

    /// iPhone → Watch
    private var commandCharacteristic: CBMutableCharacteristic?

    /// command characteristic을 구독 중인 Watch들 (central id → CBCentral)
    /// 특정 Watch에만 notify를 보내려면 CBCentral 인스턴스가 필요함
    private var subscribedCentrals: [UUID: CBCentral] = [:]

    /// 서비스가 이미 등록되어 중복 등록 방지
    private var isServiceAdded: Bool = false

    /// updateValue 내부 큐가 가득 찼을 때 재전송 대기 중인 명령
    /// peripheralManagerIsReady 콜백에서 순서대로 재전송
    private var pendingCommands: [(data: Data, centralID: UUID?, label: String)] = []

    let events: AsyncStream<BLEPeripheralEvent>
    private let continuation: AsyncStream<BLEPeripheralEvent>.Continuation

    override init() {
        let stream = AsyncStream.makeStream(of: BLEPeripheralEvent.self)

        self.events = stream.stream
        self.continuation = stream.continuation

        super.init()

        self.peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
    }

    // MARK: - Bluetooth State

    func peripheralManagerDidUpdateState(
        _ peripheral: CBPeripheralManager
    ) {
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
            resetSessionState()

            continuation.yield(
                .bluetoothStateChanged(
                    "Powered Off",
                    log: "블루투스가 비활성화"
                )
            )

        case .unauthorized:
            resetSessionState()

            continuation.yield(
                .bluetoothStateChanged(
                    "Unauthorized",
                    log: "블루투스 권한 없음"
                )
            )

        case .unsupported:
            continuation.yield(
                .bluetoothStateChanged(
                    "Unsupported",
                    log: "이 기기는 블루투스를 지원하지 않음"
                )
            )

        case .resetting:
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
        pendingCommands.removeAll()

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

        peripheralManager.add(service)
        isServiceAdded = true

        continuation.yield(
            .log("Service added")
        )
    }

    // MARK: - Advertising

    /// Watch가 검색할 수 있도록 Advertising 시작
    func startAdvertising() {
        guard let peripheralManager else { return }

        guard subscribedCentrals.count < maxSubscribers else {
            continuation.yield(.log("Slot full — skip advertising"))
            return
        }

        if peripheralManager.isAdvertising {
            return
        }

        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [BLEUUID.service],
            CBAdvertisementDataLocalNameKey: "Answer-iPhone"
        ])

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
            continuation.yield(
                .log(
                    "Advertising error: \(error.localizedDescription)"
                )
            )
        } else {
            continuation.yield(
                .log("Advertising success")
            )
        }
    }

    // MARK: - Command

    /// iPhone → Watch 명령 전송
    /// - Parameter centralID: 특정 Watch에만 보낼 때 해당 central id, nil이면 전체 브로드캐스트
    func sendCommand(_ command: BLECommand, to centralID: UUID? = nil) {
        let label = "\(command.kind)"

        // 대기 중인 명령이 있으면 순서 보장을 위해 뒤에 줄 세움
        guard pendingCommands.isEmpty else {
            pendingCommands.append((command.data, centralID, label))
            return
        }

        if !deliver(data: command.data, to: centralID, label: label) {
            pendingCommands.append((command.data, centralID, label))
            continuation.yield(.log("Command queued (BLE busy): \(label)"))
        }
    }

    /// 실제 notify 전송. 큐가 가득 차면 false 반환
    private func deliver(
        data: Data,
        to centralID: UUID?,
        label: String
    ) -> Bool {
        guard let peripheralManager, let commandCharacteristic else {
            continuation.yield(.log("Command dropped (BLE not ready): \(label)"))
            return true
        }

        var targets: [CBCentral]?

        if let centralID {
            guard let central = subscribedCentrals[centralID] else {
                // 대상 Watch가 이미 구독 해제됨 — 폐기
                continuation.yield(
                    .log("Command dropped (watch gone): \(label) → \(centralID.uuidString.prefix(8))")
                )
                return true
            }
            targets = [central]
        }

        let success = peripheralManager.updateValue(
            data,
            for: commandCharacteristic,
            onSubscribedCentrals: targets
        )

        if success {
            continuation.yield(.log("Command sent: \(label)"))
        }

        return success
    }

    /// updateValue 큐에 자리가 생기면 대기 중인 명령을 순서대로 재전송
    func peripheralManagerIsReady(
        toUpdateSubscribers peripheral: CBPeripheralManager
    ) {
        flushPendingCommands()
    }

    private func flushPendingCommands() {
        while let next = pendingCommands.first {
            guard deliver(
                data: next.data,
                to: next.centralID,
                label: next.label
            ) else { return }

            pendingCommands.removeFirst()
        }
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

        continuation.yield(
            .log("Subscribed: \(id.uuidString.prefix(8)) (\(subscribedCentrals.count)/\(maxSubscribers))")
        )

        continuation.yield(.watchConnected(id: id))

        if subscribedCentrals.count >= maxSubscribers {
            continuation.yield(.log("Slot full — stop advertising"))
            stopAdvertising()
        }
    }

    /// Watch가 구독 해제 → 슬롯 회수 + 상위 레이어에 알림
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom characteristic: CBCharacteristic
    ) {
        guard characteristic.uuid == BLEUUID.command else { return }

        let id = central.identifier
        subscribedCentrals.removeValue(forKey: id)

        continuation.yield(
            .log("Unsubscribed: \(id.uuidString.prefix(8)) (\(subscribedCentrals.count)/\(maxSubscribers))")
        )

        continuation.yield(.watchDisconnected(id: id))

        if subscribedCentrals.count < maxSubscribers {
            startAdvertising()
        }
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
