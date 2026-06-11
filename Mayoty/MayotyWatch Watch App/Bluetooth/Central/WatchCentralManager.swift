//
//  WatchCentralManager.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//

import Foundation
import CoreBluetooth

final class WatchCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var centralManager: CBCentralManager?
    private var targetPeripheral: CBPeripheral?

    /// Watch → iPhone 응답 전송용
    private var answerCharacteristic: CBCharacteristic?

    /// iPhone → Watch 명령 수신용
    private var commandCharacteristic: CBCharacteristic?

    private let commandStore: WatchCommandStore
    private var answerSender: BLEAnswerSender?

    /// 재스캔 디바운스 — 끊긴 직후 즉시 재스캔 시 ghost 연결 생성 방지
    private let rescanDelay: TimeInterval = 1.0
    private var rescanTask: Task<Void, Never>?

    /// 명시적 disconnect 진행 중 (자동 재연결 차단)
    private var isExplicitlyDisconnecting: Bool = false

    /// 전송 준비 전에 요청된 마지막 답변 — 재연결 완료 시 재전송
    private var pendingAnswer: BLEAnswer?

    let events: AsyncStream<WatchConnectionState>
    private let continuation: AsyncStream<WatchConnectionState>.Continuation
    
#if DEBUG
    /// 시뮬레이터 데모용 TCP 브리지 (-blebridge 런치 인자)
    private var bridge: BLEBridgeClient?

    private var isBridgeMode: Bool {
        ProcessInfo.processInfo.arguments.contains("-blebridge")
    }
#endif

    init(commandStore: WatchCommandStore) {
        let stream = AsyncStream.makeStream(of: WatchConnectionState.self)

        self.commandStore = commandStore
        self.events = stream.stream
        self.continuation = stream.continuation

        super.init()

#if DEBUG
        if isBridgeMode {
            startBridge()
            return
        }
#endif

        self.centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }

#if DEBUG
    private func startBridge() {
        guard bridge == nil else { return }

        let bridge = BLEBridgeClient()

        bridge.onCommand = { [weak self] command in
            self?.commandStore.handle(command)
        }

        bridge.onStateChange = { [weak self] state in
            self?.continuation.yield(state)
        }

        bridge.connect()
        self.bridge = bridge
    }
#endif

    // MARK: - Bluetooth State

    /// Watch의 Bluetooth 상태 변경 처리
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            GameLogger.bluetooth("블루투스 활성화")
            continuation.yield(.scanning)

            centralManager?.scanForPeripherals(
                withServices: [BLEUUID.service],
                options: nil
            )

        case .poweredOff:
            GameLogger.bluetooth("블루투스 비활성화")
            cleanupConnection()
            continuation.yield(.bluetoothUnavailable)

        case .unauthorized:
            GameLogger.bluetooth("블루투스 권한 없음")
            continuation.yield(.unauthorized)

        case .unsupported:
            GameLogger.bluetooth("이 기기는 블루투스를 지원하지 않음")
            continuation.yield(.bluetoothUnavailable)

        case .unknown:
            GameLogger.bluetooth("블루투스 상태 알 수 없음")
            continuation.yield(.idle)

        case .resetting:
            GameLogger.bluetooth("블루투스 재설정 중")
            cleanupConnection()
            continuation.yield(.idle)

        @unknown default:
            GameLogger.bluetooth("알 수 없는 블루투스 상태")
            continuation.yield(.idle)
        }
    }

    // MARK: - Scan

    /// iPhone Peripheral 검색 시작
    func scan() {
#if DEBUG
        if isBridgeMode {
            bridge?.connect()
            return
        }
#endif

        guard centralManager?.state == .poweredOn else {
            GameLogger.bluetooth("블루투스 상태가 올바르지 않음")
            continuation.yield(.bluetoothUnavailable)
            return
        }

        GameLogger.bluetooth("Scanning...")
        continuation.yield(.scanning)

        centralManager?.scanForPeripherals(
            withServices: [BLEUUID.service],
            options: nil
        )
    }

    // MARK: - Disconnect

    /// iPhone Peripheral 연결 해제
    func disconnect() {
        rescanTask?.cancel()
        pendingAnswer = nil

        if let peripheral = targetPeripheral {
            // didDisconnectPeripheral 콜백이 보장될 때만 플래그를 세움
            // (미연결 상태에서 세우면 되돌릴 콜백이 없어 영구 고착됨)
            isExplicitlyDisconnecting = true
            centralManager?.cancelPeripheralConnection(peripheral)
        }

        targetPeripheral = nil
        answerCharacteristic = nil
        commandCharacteristic = nil
        answerSender = nil

        GameLogger.bluetooth("Disconnected")
        continuation.yield(.disconnected)
    }

    /// 연결 관련 상태 일괄 정리 (콜백이 오지 않는 경로용)
    private func cleanupConnection() {
        targetPeripheral = nil
        answerCharacteristic = nil
        commandCharacteristic = nil
        answerSender = nil
        isExplicitlyDisconnecting = false
    }

    // MARK: - Send Answer

    /// Watch에서 선택한 응답을 iPhone으로 전송
    func send(_ answer: BLEAnswer) {
#if DEBUG
        if let bridge {
            bridge.send(answer)
            return
        }
#endif

        guard let answerSender else {
            GameLogger.bluetooth("전송 준비 안 됨. 답변 보관 후 디바운스 재스캔 예약")

            // 재연결되면 재전송 — 끊김 타이밍의 투표/지목이 유실되지 않도록
            pendingAnswer = answer

            continuation.yield(.scanning)
            scheduleRescan()
            return
        }

        GameLogger.bluetooth(
            "Send answer: kind=\(answer.kind), value=\(answer.value)"
        )

        answerSender.send(answer)
    }

    /// 디바운스 재스캔 — 이미 예약돼 있으면 무시
    private func scheduleRescan() {
        guard rescanTask == nil || rescanTask?.isCancelled == true else { return }

        rescanTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(rescanDelay))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.rescanTask = nil
                self.scan()
            }
        }
    }

    // MARK: - Connect

    /// iPhone Peripheral 발견 시 연결 시도
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        // 이미 연결된/연결 시도 중인 peripheral이면 중복 처리 방지
        guard targetPeripheral == nil else {
            GameLogger.bluetooth("이미 연결됨. discovery 무시")
            central.stopScan()
            return
        }

        GameLogger.bluetooth("Found: \(peripheral.name ?? "Unknown")")
        continuation.yield(.connecting)

        targetPeripheral = peripheral
        targetPeripheral?.delegate = self

        central.stopScan()
        central.connect(peripheral, options: nil)
    }

    /// iPhone Peripheral 연결 완료 후 서비스 검색
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        GameLogger.bluetooth("iPhone과 연결")
        continuation.yield(.connecting)

        peripheral.discoverServices([BLEUUID.service])
    }

    /// iPhone Peripheral 연결 실패 처리
    /// 연결 실패 시 didDisconnectPeripheral은 호출되지 않으므로 여기서 직접 정리해야
    /// targetPeripheral이 남아 이후 모든 discovery가 무시되는 데드락을 막을 수 있음
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        GameLogger.bluetooth(
            "Connect failed: \(error?.localizedDescription ?? "unknown")"
        )

        targetPeripheral = nil
        answerCharacteristic = nil
        commandCharacteristic = nil
        answerSender = nil

        continuation.yield(.failed)
        scheduleRescan()
    }

    /// iPhone Peripheral 연결 해제 처리
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        targetPeripheral = nil
        answerCharacteristic = nil
        commandCharacteristic = nil
        answerSender = nil

        GameLogger.bluetooth("Disconnected")
        continuation.yield(.disconnected)

        // 명시적 disconnect가 아닌 경우만 디바운스 후 재스캔
        if isExplicitlyDisconnecting {
            isExplicitlyDisconnecting = false
        } else {
            scheduleRescan()
        }
    }

    // MARK: - Discover Service

    /// BLE Service 검색 결과 처리
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error {
            GameLogger.bluetooth(
                "Discover services error: \(error.localizedDescription)"
            )
            continuation.yield(.failed)
            return
        }

        guard let services = peripheral.services else { return }

        for service in services where service.uuid == BLEUUID.service {
            peripheral.discoverCharacteristics(
                [
                    BLEUUID.answer,
                    BLEUUID.command
                ],
                for: service
            )
        }
    }

    // MARK: - Discover Characteristics

    /// answer, command Characteristic 검색 결과 처리
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error {
            GameLogger.bluetooth(
                "Discover characteristics error: \(error.localizedDescription)"
            )
            continuation.yield(.failed)
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            switch characteristic.uuid {
            case BLEUUID.answer:
                answerCharacteristic = characteristic

                answerSender = BLEAnswerSender(
                    peripheral: peripheral,
                    characteristic: characteristic
                )

                GameLogger.bluetooth("응답 전송 준비 완료")

            case BLEUUID.command:
                commandCharacteristic = characteristic

                peripheral.setNotifyValue(
                    true,
                    for: characteristic
                )

                GameLogger.bluetooth("명령 수신 준비 완료")

            default:
                break
            }
        }

        if answerCharacteristic != nil,
           commandCharacteristic != nil {
            continuation.yield(.connected)

            GameLogger.bluetooth("참가 신호 전송")
            answerSender?.sendJoin()

            // 끊김 동안 보관해 둔 답변 재전송
            if let pendingAnswer {
                GameLogger.bluetooth("보관 답변 재전송: \(pendingAnswer.kind)")
                answerSender?.send(pendingAnswer)
                self.pendingAnswer = nil
            }
        }
    }

    // MARK: - Receive Command

    /// iPhone에서 notify로 보낸 BLECommand 수신
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            GameLogger.bluetooth(
                "Command receive failed: \(error.localizedDescription)"
            )
            return
        }

        guard characteristic.uuid == BLEUUID.command,
              let data = characteristic.value,
              let command = BLECommand(data: data)
        else { return }

        GameLogger.bluetooth(
            "Command received: kind=\(command.kind), value=\(command.value)"
        )

        commandStore.handle(command)
    }

    // MARK: - Write Result

    /// Watch → iPhone 응답 전송 결과 처리
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            GameLogger.bluetooth("Write failed: \(error.localizedDescription)")
            continuation.yield(.sendAnswerFailed)
        } else {
            GameLogger.bluetooth("쓰기 성공")
            continuation.yield(.sendAnswerSuccess)
        }
    }
}
