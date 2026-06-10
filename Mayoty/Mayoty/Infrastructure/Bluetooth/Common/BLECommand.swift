//
//  BLECommand.swift
//  Mayoty
//
//  Created by sun on 6/11/26.
//

import Foundation

enum BLECommandKind: UInt8 {
    case connectionWaiting = 0
    case connectionFailed = 1
    case connectionSucceeded = 2

    case waitingPlayers = 3
    case gameStart = 4
    case roleAssigning = 5
    case roleResult = 6

    case dayTime = 7

    case mafiaTurn = 8
    case policeTurn = 9
    case policeResult = 10
    case doctorTurn = 11
    case nightWaiting = 12

    case vote = 13
    case finalDefense = 14
    case executionVote = 15
    case executionResult = 16

    case gameEnded = 17
    case playerColor = 18
}

struct BLECommand {
    let kind: BLECommandKind

    let targetID: UInt8

    let value: UInt8

    var data: Data {
        Data([kind.rawValue, targetID, value])
    }

    init(
        kind: BLECommandKind,
        targetID: UInt8 = 0,
        value: UInt8 = 0
    ) {
        self.kind = kind
        self.targetID = targetID
        self.value = value
    }

    init?(data: Data) {
        guard data.count >= 3,
              let kind = BLECommandKind(rawValue: data[0])
        else { return nil }

        self.kind = kind
        self.targetID = data[1]
        self.value = data[2]
    }
}

extension BLECommand {
    static func connectionWaiting() -> BLECommand {
        BLECommand(kind: .connectionWaiting)
    }

    static func connectionFailed() -> BLECommand {
        BLECommand(kind: .connectionFailed)
    }

    static func connectionSucceeded() -> BLECommand {
        BLECommand(kind: .connectionSucceeded)
    }

    static func waitingPlayers(count: UInt8) -> BLECommand {
        BLECommand(
            kind: .waitingPlayers,
            value: count
        )
    }

    static func gameStart() -> BLECommand {
        BLECommand(kind: .gameStart)
    }

    static func roleAssigning() -> BLECommand {
        BLECommand(kind: .roleAssigning)
    }

    static func roleResult(
        targetID: UInt8,
        role: Role
    ) -> BLECommand {
        BLECommand(
            kind: .roleResult,
            targetID: targetID,
            value: role.bleValue
        )
    }

    static func dayTime() -> BLECommand {
        BLECommand(kind: .dayTime)
    }

    static func mafiaTurn(targetID: UInt8) -> BLECommand {
        BLECommand(
            kind: .mafiaTurn,
            targetID: targetID
        )
    }

    static func policeTurn(targetID: UInt8) -> BLECommand {
        BLECommand(
            kind: .policeTurn,
            targetID: targetID
        )
    }
    
    static func policeResult(
        targetID: UInt8,
        isMafia: Bool
    ) -> BLECommand {
        BLECommand(
            kind: .policeResult,
            targetID: targetID,
            value: isMafia ? 1 : 0
        )
    }

    static func doctorTurn(targetID: UInt8) -> BLECommand {
        BLECommand(
            kind: .doctorTurn,
            targetID: targetID
        )
    }

    static func nightWaiting(targetID: UInt8) -> BLECommand {
        BLECommand(
            kind: .nightWaiting,
            targetID: targetID
        )
    }

    static func vote() -> BLECommand {
        BLECommand(kind: .vote)
    }

    static func finalDefense() -> BLECommand {
        BLECommand(kind: .finalDefense)
    }

    static func executionVote() -> BLECommand {
        BLECommand(kind: .executionVote)
    }

    static func gameEnded(winner: Team) -> BLECommand {
        BLECommand(
            kind: .gameEnded,
            value: winner.bleValue
        )
    }
}

extension Role {
    var bleValue: UInt8 {
        switch self {
        case .mafia:
            return 1
        case .police:
            return 2
        case .doctor:
            return 3
        case .citizen:
            return 4
        }
    }
}

extension Team {
    var bleValue: UInt8 {
        switch self {
        case .mafia:
            return 1
        case .citizens:
            return 2
        }
    }

    init?(bleValue: UInt8) {
        switch bleValue {
        case 1:
            self = .mafia
        case 2:
            self = .citizens
        default:
            return nil
        }
    }
}

extension PlayerColor {
    var bleValue: UInt8 {
        switch self {
        case .pink: return 1
        case .purple: return 2
        case .yellow: return 3
        case .orange: return 4
        case .mint: return 5
        }
    }

    init?(bleValue: UInt8) {
        switch bleValue {
        case 1: self = .pink
        case 2: self = .purple
        case 3: self = .yellow
        case 4: self = .orange
        case 5: self = .mint
        default: return nil
        }
    }
}
