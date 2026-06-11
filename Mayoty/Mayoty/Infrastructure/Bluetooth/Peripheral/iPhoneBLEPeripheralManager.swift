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
    case answerReceived(id: UUID, answer: BLEAnswer)
    case log(String)
}

final class iPhoneBLEPeripheralManager: NSObject, CBPeripheralManagerDelegate {

    private var peripheralManager: CBPeripheralManager?

    /// Watch → iPhone
    private var answerCharacteristic: CBMutableCharacteristic?

    /// iPhone → Watch
    private var commandCharacteristic: CBMutableCharacteristic?

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
            continuation.yield(
                .bluetoothStateChanged(
                    "Powered Off",
                    log: "블루투스가 비활성화"
                )
            )

        case .unauthorized:
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

    // MARK: - Service

    /// BLE Service와 Characteristic을 등록
    private func setupService() {
        guard let peripheralManager else { return }

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

        peripheralManager.removeAllServices()
        peripheralManager.add(service)

        continuation.yield(
            .log("Service added")
        )
    }

    // MARK: - Advertising

    /// Watch가 검색할 수 있도록 Advertising 시작
    func startAdvertising() {
        guard let peripheralManager else { return }

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
    func sendCommand(_ command: BLECommand) {
        guard let peripheralManager else { return }
        guard let commandCharacteristic else { return }

        let success = peripheralManager.updateValue(
            command.data,
            for: commandCharacteristic,
            onSubscribedCentrals: nil
        )

        continuation.yield(
            .log(
                success
                ? "Command sent: \(command.kind)"
                : "Command send failed"
            )
        )
    }

    // MARK: - Receive Answer

    /// Watch가 보낸 응답을 수신
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        for request in requests {

            guard request.characteristic.uuid == BLEUUID.answer else {
                peripheral.respond(
                    to: request,
                    withResult: .requestNotSupported
                )
                continue
            }

            let centralID = request.central.identifier

            continuation.yield(
                .watchConnected(id: centralID)
            )

            guard let data = request.value,
                  let answer = BLEAnswer(data: data)
            else {
                peripheral.respond(
                    to: request,
                    withResult: .invalidAttributeValueLength
                )
                continue
            }

            continuation.yield(
                .answerReceived(
                    id: centralID,
                    answer: answer
                )
            )

            peripheral.respond(
                to: request,
                withResult: .success
            )
        }
    }
}
