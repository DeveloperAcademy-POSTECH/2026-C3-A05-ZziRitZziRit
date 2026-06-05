//
//  WatchCentralManager.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//
import Foundation
import CoreBluetooth

final class WatchCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{

    private var centralManager: CBCentralManager?
    private var targetPeripheral: CBPeripheral?
    private var answerCharacteristic: CBCharacteristic?
    
    private let model: WatchViewModel
    private var pendingAnswer: BLEMessage?
    
    init(model: WatchViewModel){
        self.model = model
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }


    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case.poweredOn:
            model.status = "Powered On"
            model.addLog("블루투스 활성화")
        case.poweredOff:
            model.status = "Powered Off"
            model.addLog("블루투스 비활성화")
        case.unauthorized:
            model.status = "Unauthorized"
            model.addLog("블루투스 비활성화")
        case.unsupported:
            model.status = "Unsupported"
            model.addLog("이 기기는 블루투스를 지원하지 않습니다")
        case .unknown:
            model.status = "Unknown"
        case .resetting:
            model.status = "Resetting"
        default:
            model.status = "Bluetooth not ready"
        }
    }
    
    

    func scan(){
        guard centralManager?.state == .poweredOn else {
            model.addLog("블루투스 상태가 올바르지 않음")
            return
        }
        model.addLog("Start scan...")
        
        centralManager?.scanForPeripherals(
            withServices: [BLEUUID.service],
            options: nil)
    }
    
    

    func disconnect(){
        if let peripheral = targetPeripheral{
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        
        targetPeripheral = nil
        answerCharacteristic = nil
        model.status = "Disconnected"
        model.addLog("Disconnected")
    }
    
    

    func sendSaveOrKill(_ answer: BLEsaveOrKill){
        send(BLEMessage(kind: .saveOrKill, value: answer.rawValue))
    }
    
    func sendSelectPlayer(_ playerNumber: UInt8){
        send(BLEMessage(kind:.selectPlayer, value: playerNumber))
    }
    
    
    
    private func send(_ message: BLEMessage) {
        guard let peripheral = targetPeripheral,
              let characteristic = answerCharacteristic
        else {
            pendingAnswer = message
            model.addLog("다시 검색합니다")
            scan()
            return
        }
        
        peripheral.writeValue(message.data, for: characteristic, type: .withResponse)
        
//      여기 어떻게 수정하지
//      model.status = "Sent \(answer == .kill ? "죽이기" : "살리기")"
//      model.addLog("Sent \(answer == .kill ? "죽이기" : "살리기")"
        
    }
    

    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        model.status = "iPhone 발견"
        model.addLog("Found: \(peripheral.name ?? "Unknown")")
        
        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
        
        centralManager?.stopScan()
        centralManager?.connect(peripheral, options: nil)
    }
    

    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        model.status = "Connected"
        model.addLog("iPhone과 연결됨")
        peripheral.discoverServices([BLEUUID.service])
    }
    
    

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        model.status = "Connect Failed"
        model.addLog("Connect Failed: \(error?.localizedDescription ?? "Unknown Error")")
    }
    
    

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        model.status = "Disconnected"
        model.addLog("Disconnected")
        
        targetPeripheral = nil
        answerCharacteristic = nil
    }
    


    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error{
            model.addLog("Discover services error: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services where service.uuid == BLEUUID.service {
            peripheral.discoverCharacteristics([BLEUUID.answer], for: service)
        }
    }
    


    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error{
            model.addLog("Discover characteristics error: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics where characteristic.uuid == BLEUUID.answer {
            answerCharacteristic = characteristic
            model.status = "Ready"
            model.addLog("Ready to send")
            
            if let pendingAnswer{
                self.pendingAnswer = nil
                send(pendingAnswer)
            }
        }
    }
    


    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error{
            model.status = "Write failed"
            model.addLog("Write failed: \(error.localizedDescription)")
        }else{
            model.status = "Write success"
            model.addLog("쓰기 성공")
        }
    }
    
}

