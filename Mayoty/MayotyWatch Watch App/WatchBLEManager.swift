//
//  WatchCentralManager.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//
import Foundation
import CoreBluetooth

final class WatchBLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    private var targetPeripheral: CBPeripheral?
    private var answerCharacteristic: CBCharacteristic?
    private var sendAnswerManager: SendAnswerManager?
    
    var onConnectionStateChanged: ((WatchConnectionState) -> Void)?
    
    private var connectionStateMessage: WatchConnectionState = .idle
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    
//연결상태 업데이트 담당
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case.poweredOn:
            connectionStateMessage = .scanning
            
            centralManager?.scanForPeripherals(withServices: [BLEUUID.service], options: nil)
            
        case.poweredOff:
            connectionStateMessage = .bluetoothUnavailable
            
        case.unauthorized:
            connectionStateMessage = .unautorized
            
        case.unsupported:
            connectionStateMessage = .bluetoothUnavailable
            
        case.unknown:
            connectionStateMessage = .idle
            
        default:
            break
        }
        
        
    }
    
    func scan(){
        guard centralManager?.state == .poweredOn else {
            connectionStateMessage = .bluetoothUnavailable
            return
        }
        
        centralManager?.scanForPeripherals(withServices: [BLEUUID.service], options: nil)
    }
    
    
    
    func disconnect(){
        if let peripheral = targetPeripheral{
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        
        targetPeripheral = nil
        answerCharacteristic = nil
        connectionStateMessage = .disconnected
    }
    
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        connectionStateMessage = .connecting
        
        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
        
        central.stopScan()
        centralManager?.connect(targetPeripheral!, options: nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionStateMessage = .connecting
        
        peripheral.discoverServices([BLEUUID.service])
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        connectionStateMessage = .failed
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        connectionStateMessage = .disconnected
        
        targetPeripheral = nil
        answerCharacteristic = nil
    }
    
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error{
            connectionStateMessage = .failed
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services where service.uuid == BLEUUID.service {
            peripheral.discoverCharacteristics([BLEUUID.answer], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error{
            connectionStateMessage = .failed
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics where characteristic.uuid == BLEUUID.answer {
            // 1. Characteristic 저장
            answerCharacteristic = characteristic
            
            // 2. SendAnswerManager 생성
            sendAnswerManager = SendAnswerManager(peripheral: peripheral, characteristic: characteristic)
            
            // 3. register 메시지 전송
            let answer = BLEAnswer(type: .register(PlayerID: PlayerID.shared.id))
            sendAnswerManager?.send(answer)
            
            // 4. 상태 업데이트
            connectionStateMessage = .connected
        }
    }
    
//SendAnswerManager에서 peripheral(.writeValue() 호출) : 실제 데이터를 peripheral에 write(send)
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error{
            connectionStateMessage = .sendAnswerFailed
        }else{
            //결과가 잘 보내졌는지 확인
            connectionStateMessage = .sendAnswerSuccess
        }
    }
    
}
