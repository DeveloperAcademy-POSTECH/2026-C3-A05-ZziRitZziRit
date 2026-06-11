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

    /// 대상 플레이어 사망 통지 — 사망자 전용 플로우 진입 (타깃 전송 전용)
    case youDied = 19

    /// 특정 플레이어의 직업 공개 — 사망자의 진실 확인 화면용 (타깃 전송 전용)
    case playerRole = 20

    /// 특정 플레이어 사망 상태 동기화 — 생존자 워치의 명단 표시용
    /// (targetID = 사망한 플레이어 번호)
    case playerDied = 21
}

// 페이로드 규약 (3바이트: kind, targetID, value)
// - mafiaTurn/policeTurn/doctorTurn : value = 남은 시간(초)
// - nightWaiting                    : value = 진행 중인 직업(bleValue)
// - vote                            : value = 남은 시간(초)
// - finalDefense / executionVote    : targetID = 변론자 번호, value = 남은 시간(초)
// - executionResult                 : targetID = 변론자 번호, value = 처형 여부(1/0)
// - policeResult                    : targetID = 수사 대상 번호, value = 마피아 여부(1/0)
// - roleResult                      : targetID = 수신자 자신의 플레이어 번호

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

    static func mafiaTurn(targetID: UInt8, seconds: UInt8) -> BLECommand {
        BLECommand(
            kind: .mafiaTurn,
            targetID: targetID,
            value: seconds
        )
    }

    static func policeTurn(targetID: UInt8, seconds: UInt8) -> BLECommand {
        BLECommand(
            kind: .policeTurn,
            targetID: targetID,
            value: seconds
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

    static func doctorTurn(targetID: UInt8, seconds: UInt8) -> BLECommand {
        BLECommand(
            kind: .doctorTurn,
            targetID: targetID,
            value: seconds
        )
    }

    static func nightWaiting(
        targetID: UInt8,
        activeRole: Role
    ) -> BLECommand {
        BLECommand(
            kind: .nightWaiting,
            targetID: targetID,
            value: activeRole.bleValue
        )
    }

    static func vote(seconds: UInt8) -> BLECommand {
        BLECommand(kind: .vote, value: seconds)
    }

    static func finalDefense(
        defendantID: UInt8,
        seconds: UInt8
    ) -> BLECommand {
        BLECommand(
            kind: .finalDefense,
            targetID: defendantID,
            value: seconds
        )
    }

    static func executionVote(
        defendantID: UInt8,
        seconds: UInt8
    ) -> BLECommand {
        BLECommand(
            kind: .executionVote,
            targetID: defendantID,
            value: seconds
        )
    }

    static func executionResult(
        defendantID: UInt8,
        didExecute: Bool
    ) -> BLECommand {
        BLECommand(
            kind: .executionResult,
            targetID: defendantID,
            value: didExecute ? 1 : 0
        )
    }

    static func playerDied(targetID: UInt8) -> BLECommand {
        BLECommand(
            kind: .playerDied,
            targetID: targetID
        )
    }

    static func gameEnded(winner: Team) -> BLECommand {
        BLECommand(
            kind: .gameEnded,
            value: winner.bleValue
        )
    }

    static func youDied() -> BLECommand {
        BLECommand(kind: .youDied)
    }

    static func playerRole(
        targetID: UInt8,
        role: Role
    ) -> BLECommand {
        BLECommand(
            kind: .playerRole,
            targetID: targetID,
            value: role.bleValue
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
