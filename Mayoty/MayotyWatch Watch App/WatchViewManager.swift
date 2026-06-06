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
    
    private let centralManager: WatchBLEManager
    
    init(){
        self.centralManager = WatchBLEManager()
        
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
    

    
//    func returnToStart(){
//        첫번째 워치 뷰로 이동하기
//    }
    
    
//    func viewPlayerRole(){
//        살아있는 플레이어 직업 확인(이미 죽은 경우)
//    }
    
}
