//
//  BLEAnswer.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//

import Foundation

enum BLEAnswerKind: UInt8 {
    case saveOrKill = 0
    case selectPlayer = 1
}

enum BLESaveOrKill: UInt8 {
    case save = 0
    case kill = 1
}

struct BLEAnswer {
    let kind: BLEAnswerKind
    let value: UInt8
    
    var data: Data {
        Data([kind.rawValue, value])
    }
    
    init(kind: BLEAnswerKind, value: UInt8) {
        self.kind = kind
        self.value = value
    }
    
    init?(data: Data) {
        guard data.count >= 2,
              let kind = BLEAnswerKind(rawValue: data[0])
        else { return nil }
        
        self.kind = kind
        self.value = data[1]
    }
}
