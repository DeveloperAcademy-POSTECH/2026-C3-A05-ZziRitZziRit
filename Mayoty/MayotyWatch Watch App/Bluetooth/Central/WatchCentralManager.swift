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

    let events: AsyncStream<WatchConnectionState>
    private let continuation: AsyncStream<WatchConnectionState>.Continuation
    
    init(commandStore: WatchCommandStore) {
        let stream = AsyncStream.makeStream(of: WatchConnectionState.self)

        self.commandStore = commandStore
        self.events = stream.stream
        self.continuation = stream.continuation

        super.init()

        self.centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }

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
            continuation.yield(.idle)

        @unknown default:
            GameLogger.bluetooth("알 수 없는 블루투스 상태")
            continuation.yield(.idle)
        }
    }

    // MARK: - Scan

    /// iPhone Peripheral 검색 시작
    func scan() {
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
        if let peripheral = targetPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }

        targetPeripheral = nil
        answerCharacteristic = nil
        commandCharacteristic = nil
        answerSender = nil

        GameLogger.bluetooth("Disconnected")
        continuation.yield(.disconnected)
    }

    // MARK: - Send Answer

    /// Watch에서 선택한 응답을 iPhone으로 전송
    func send(_ answer: BLEAnswer) {
        guard let answerSender else {
            GameLogger.bluetooth("전송 준비 안 됨. 다시 검색합니다")
            continuation.yield(.scanning)
            scan()
            return
        }

        GameLogger.bluetooth(
            "Send answer: kind=\(answer.kind), value=\(answer.value)"
        )

        answerSender.send(answer)
    }

    // MARK: - Connect

    /// iPhone Peripheral 발견 시 연결 시도
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
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
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        GameLogger.bluetooth(
            "Connect failed: \(error?.localizedDescription ?? "unknown")"
        )

        continuation.yield(.failed)
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
