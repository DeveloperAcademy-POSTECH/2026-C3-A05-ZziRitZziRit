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
    private var answerCharacteristic: CBCharacteristic?
    private var answerSender: BLEAnswerSender?

    let events: AsyncStream<WatchConnectionState>
    private let continuation: AsyncStream<WatchConnectionState>.Continuation

    override init() {
        let stream = AsyncStream.makeStream(of: WatchConnectionState.self)

        self.events = stream.stream
        self.continuation = stream.continuation

        super.init()

        self.centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }

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
            continuation.yield(.unautorized)

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

    func disconnect() {
        if let peripheral = targetPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }

        targetPeripheral = nil
        answerCharacteristic = nil
        answerSender = nil

        GameLogger.bluetooth("Disconnected")
        continuation.yield(.disconnected)
    }

    func send(_ answer: BLEAnswer) {
        guard let answerSender else {
            GameLogger.bluetooth("전송 준비 안 됨. 다시 검색합니다")
            continuation.yield(.scanning)
            scan()
            return
        }

        GameLogger.bluetooth("Send answer: kind=\(answer.kind), value=\(answer.value)")
        answerSender.send(answer)
    }

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

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        GameLogger.bluetooth("iPhone과 연결")
        continuation.yield(.connecting)

        peripheral.discoverServices([BLEUUID.service])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        GameLogger.bluetooth("Connect failed: \(error?.localizedDescription ?? "unknown")")
        continuation.yield(.failed)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        targetPeripheral = nil
        answerCharacteristic = nil
        answerSender = nil

        GameLogger.bluetooth("Disconnected")
        continuation.yield(.disconnected)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error {
            GameLogger.bluetooth("Discover services error: \(error.localizedDescription)")
            continuation.yield(.failed)
            return
        }

        guard let services = peripheral.services else { return }

        for service in services where service.uuid == BLEUUID.service {
            peripheral.discoverCharacteristics(
                [BLEUUID.answer],
                for: service
            )
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error {
            GameLogger.bluetooth("Discover characteristics error: \(error.localizedDescription)")
            continuation.yield(.failed)
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics where characteristic.uuid == BLEUUID.answer {
            answerCharacteristic = characteristic

            answerSender = BLEAnswerSender(
                peripheral: peripheral,
                characteristic: characteristic
            )

            GameLogger.bluetooth("Ready to send")
            continuation.yield(.connected)
        }
    }

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
