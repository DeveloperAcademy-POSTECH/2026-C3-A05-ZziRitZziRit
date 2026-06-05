//
//  WatchCentralManager.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//
import Foundation
import CoreBluetooth

final class WatchCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var onConnectionStateChanged: ((WatchConnectionState) -> Void)?
    
    private var centralManager: CBCentralManager?
    private var targetPeripheral: CBPeripheral?
    private var answerCharacteristic: CBCharacteristic?
    
    private var pendingAnswer: BLEAnswer?  //보류중인 응답
    
    override init(){
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }


//Central manager 업데이트 알림
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            return
        }
        
        onConnectionStateChanged?(.idle)
    }
    
    
//peripheral을 찾고 난 다음 Service 탐색
    func scan(){
        guard centralManager?.state == .poweredOn else {
            return
        }
        
        onConnectionStateChanged?(.scanning)
        
        centralManager?.scanForPeripherals(withServices: [BLEUUID.service], options: nil)
    }
    
    
//Central에서 연결 끊을 경우
    func disconnect(){
        if let peripheral = targetPeripheral{
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        
        targetPeripheral = nil
        answerCharacteristic = nil
        onConnectionStateChanged?(.disconnected)
    }
    
    
//BLEAnswer 보내기
    func sendSaveOrKill(_ answer: BLEsaveOrKill){
        send(BLEAnswer(kind: .saveOrKill, value: answer.rawValue))
    }
    
    func sendSelectPlayer(_ playerNumber: UInt8){
        send(BLEAnswer(kind:.selectPlayer, value: playerNumber))
    }
    
    
    
    private func send(_ answer: BLEAnswer) {
        guard let peripheral = targetPeripheral,
              let characteristic = answerCharacteristic
        else {
            pendingAnswer = answer
            scan()
            return
        }
        
        peripheral.writeValue(answer.data, for: characteristic, type: .withResponse)
    }
    
    
    

//central이 peripheral을 발견했음을 알림
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
        
        onConnectionStateChanged?(.connecting)
        
        centralManager?.stopScan()
        centralManager?.connect(peripheral, options: nil)
    }
    

//central이 peripheral과 연결했음을 delegate에 알림
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        onConnectionStateChanged?(.connected)
        peripheral.discoverServices([BLEUUID.service])
    }
    
    
//central가 peripheral과 연결을 생성하지 못했음을 delegate에 알림
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        targetPeripheral = nil
        answerCharacteristic = nil
        onConnectionStateChanged?(.failed)
    }
    
    
//central가 peripheral과 연결이 끊어진 것을 delegate에 알림
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        targetPeripheral = nil
        answerCharacteristic = nil
        onConnectionStateChanged?(.disconnected)
    }
    


//central에서 peripheral의 service 검색이 성공했음을 알림
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        
        guard error == nil,
              let services = peripheral.services
        else {
            onConnectionStateChanged?(.failed)
            return
        }
        
        for service in services where service.uuid == BLEUUID.service {
            peripheral.discoverCharacteristics([BLEUUID.answer], for: service)
        }
    }
    


//PeripheralDelegate에게 지정된 특성의 값을 검색하는데 성공했음을 알려주거나 특성의 값이 변경된 것을 알림
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        
        guard error == nil,
              let characteristics = service.characteristics
        else {
            onConnectionStateChanged?(.failed)
            return
        }
        
        for characteristic in characteristics where characteristic.uuid == BLEUUID.answer {
            answerCharacteristic = characteristic
            
            if let pendingAnswer{
                self.pendingAnswer = nil
                send(pendingAnswer)
            }
        }
    }
    


//Peripheral의 characteristic에 대한 값 쓰기
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?
    ) {
        if error != nil {
            onConnectionStateChanged?(.failed)
        }
    }
    
}
