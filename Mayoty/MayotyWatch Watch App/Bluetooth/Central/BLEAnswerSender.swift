//
//  BLEAnswerSender.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//

import CoreBluetooth

final class BLEAnswerSender {
    private let peripheral: CBPeripheral
    private let characteristic: CBCharacteristic

    init(
        peripheral: CBPeripheral,
        characteristic: CBCharacteristic
    ) {
        self.peripheral = peripheral
        self.characteristic = characteristic
    }
    
    func sendJoin() {
        send(.join())
    }

    func send(_ answer: BLEAnswer) {
        let writeType: CBCharacteristicWriteType =
            characteristic.properties.contains(.write)
            ? .withResponse
            : .withoutResponse

        peripheral.writeValue(
            answer.data,
            for: characteristic,
            type: writeType
        )
    }
}
