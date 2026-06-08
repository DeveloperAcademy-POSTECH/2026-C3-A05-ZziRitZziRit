//
//  BLEAnswer.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//

import Foundation

enum BLEAnswerKind: UInt8 {
    case mafiaSelected = 0
    case policeSelected = 1
    case doctorSelected = 2
    case voteSubmitted = 3
    case executionVoteSubmitted = 4
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

extension BLEAnswer {
    static func doctorSelected(playerID: UInt8) -> BLEAnswer {
        BLEAnswer(kind: .doctorSelected, value: playerID)
    }

    static func mafiaSelected(playerID: UInt8) -> BLEAnswer {
        BLEAnswer(kind: .mafiaSelected, value: playerID)
    }

    static func policeSelected(playerID: UInt8) -> BLEAnswer {
        BLEAnswer(kind: .policeSelected, value: playerID)
    }

    static func voteSubmitted(targetID: UInt8) -> BLEAnswer {
        BLEAnswer(kind: .voteSubmitted, value: targetID)
    }

    static func executionVoteSubmitted(isAgree: Bool) -> BLEAnswer {
        BLEAnswer(
            kind: .executionVoteSubmitted,
            value: isAgree ? 1 : 0
        )
    }
}

extension BLEAnswer {
    var kindText: String {
        switch kind {
        case .doctorSelected:
            return "의사 지목"
        case .mafiaSelected:
            return "마피아 지목"
        case .policeSelected:
            return "경찰 지목"
        case .voteSubmitted:
            return "낮 투표"
        case .executionVoteSubmitted:
            return "최종 투표"
        }
    }
}
