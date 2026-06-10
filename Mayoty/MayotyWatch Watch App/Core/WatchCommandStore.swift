//
//  WatchCommandStore.swift
//  Mayoty
//
//  Created by sun on 6/11/26.
//

import Observation

@Observable
@MainActor
final class WatchCommandStore {

    var currentScreen: WatchScreen = .join

    /// 밤 선택 화면에서 사용
    var players: [Player] = []

    /// 역할 공개 화면에서 사용
    var role: Role = .citizen

    /// 경찰 수사 결과 화면에서 사용
    var policeResultIsMafia: Bool = false

    /// 게임 결과 화면에서 사용
    var winner: Team = .citizens

    func handle(_ command: BLECommand) {
        switch command.kind {
        case .playerColor:
            updatePlayerColor(
                targetID: command.targetID,
                value: command.value
            )

        case .roleAssigning:
            currentScreen = .roleAssigning

        case .roleResult:
            role = Role(bleValue: command.value) ?? .citizen
            currentScreen = .roleResult

        case .dayTime:
            currentScreen = .dayTime

        case .mafiaTurn:
            currentScreen = .mafiaTurn

        case .policeTurn:
            currentScreen = .policeTurn

        case .doctorTurn:
            currentScreen = .doctorTurn

        case .nightWaiting:
            currentScreen = .nightTime

        case .policeResult:
            policeResultIsMafia = command.value == 1
            currentScreen = .policeResult

        case .vote:
            currentScreen = .vote

        case .finalDefense:
            currentScreen = .finalDefense

        case .executionVote:
            currentScreen = .executionVote

        case .executionResult:
            currentScreen = .executionResult

        case .gameEnded:
            winner = Team(bleValue: command.value) ?? .citizens
            currentScreen = .gameEnded

        default:
            break
        }
    }

    private func updatePlayerColor(
        targetID: UInt8,
        value: UInt8
    ) {
        guard let color = PlayerColor(bleValue: value) else { return }

        let index = Int(targetID) - 1
        guard index >= 0 else { return }

        while players.count <= index {
            players.append(Player(color: .pink))
        }

        players[index] = Player(color: color)
    }
}
