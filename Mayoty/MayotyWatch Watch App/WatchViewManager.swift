//
//  WatchViewModel.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//
import Foundation
import Observation
@Observable
final class WatchViewManager {
    var connectionState: WatchConnectionState = .idle
    
    private let centralManager: WatchCentralManager
    
    init(){
        self.centralManager = WatchCentralManager()
        
        self.centralManager.onConnectionStateChanged = { [weak self] state in
            self?.connectionState = state
        }
    }
    
    
    
    //참가하기, 다시 시도 버튼 누르면 실행
    func scan(){
        centralManager.scan()
    }
    
    //블루투스 연결 실패 시 실행
    func disconnect(){
        centralManager.disconnect()
    }
    
    //죽이기/살리기 선택하면 실행됨(peripheral에 응답 보내기)
    func sendSaveOrKill(_ answer: BLEsaveOrKill){
        centralManager.sendSaveOrKill(answer)
    }
    
    //플레이어 선택하면 실행됨(peripheral에 응답 보내기)
    func sendSelectPlayer(_ playerNumber: UInt8){
        centralManager.sendSelectPlayer(playerNumber)
    }
    
//    func returnToStart(){
//        첫번째 워치 뷰로 이동하기
//    }
    
    
//    func viewPlayerRole(){
//        살아있는 플레이어 직업 확인(이미 죽은 경우)
//    }
    
}
