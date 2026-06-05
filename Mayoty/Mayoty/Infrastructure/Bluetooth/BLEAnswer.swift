//
//  BLEAnswer.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//

import Foundation
import CoreBluetooth

//메세지 종류(죽이기 살리기 투표, 플레이어 지목), 디폴트값은 save!
enum BLEMessageKind: UInt8{
    case saveOrKill = 1
    case selectPlayer = 2       //아무도 선택 안하면 nil반환!
}

//죽이기 살리기 투표
enum BLEsaveOrKill: UInt8{
    case save = 0
    case kill = 1
}

//메세지 구조
struct BLEMessage{
    let kind: BLEMessageKind
    let value: UInt8
    
    var data: Data{
        Data([kind.rawValue,value])
    }
    
    init(kind: BLEMessageKind, value: UInt8) {
        self.kind = kind
        self.value = value
    }
    
    init?(data:Data) {
        guard data.count >= 2,
              let kind = BLEMessageKind(rawValue: data[0])
        else {return nil}
        
        self.kind = kind
        self.value = data[1]
        
    }
}
