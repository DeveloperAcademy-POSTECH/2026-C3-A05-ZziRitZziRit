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

    /// 처형 결과 화면에서 사용
    var executionResult: ExecutionResult = .survive

    /// 대기 화면의 접속 인원 표시에 사용
    var waitingCount: Int = 0

    func handle(_ command: BLECommand) {
        switch command.kind {
        case .connectionSucceeded:
            currentScreen = .connectionSucceeded

            Task {
                try? await Task.sleep(for: .seconds(2))

                // 2초 사이에 다른 명령으로 화면이 바뀌었으면 되돌리지 않음
                guard currentScreen == .connectionSucceeded else { return }
                currentScreen = .waiting
            }

        case .connectionFailed:
            currentScreen = .connectionFailed

        case .waitingPlayers:
            waitingCount = Int(command.value)

            // 게임 종료 후 새 로비가 열리면 대기 화면으로 복귀
            if currentScreen == .gameEnded {
                returnToWaiting()
            }

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
            executionResult = command.value == 1 ? .dead : .survive
            currentScreen = .executionResult

        case .gameEnded:
            winner = Team(bleValue: command.value) ?? .citizens
            currentScreen = .gameEnded

        case .youDied:
            // 사망자 플로우 내부 탐색 중 반복 수신돼도 처음으로 끌려가지 않도록
            if currentScreen != .dead {
                currentScreen = .dead
            }

        case .playerRole:
            updatePlayerRole(
                targetID: command.targetID,
                value: command.value
            )

        default:
            break
        }
    }

    /// 게임 종료 후 새 게임 대기 상태로 복귀
    func returnToWaiting() {
        players = []
        role = .citizen
        policeResultIsMafia = false
        executionResult = .survive
        currentScreen = .waiting
    }

    private func updatePlayerColor(
        targetID: UInt8,
        value: UInt8
    ) {
        guard let color = PlayerColor(bleValue: value) else { return }

        let index = Int(targetID) - 1
        guard index >= 0 else { return }

        ensurePlayerCapacity(through: index)

        players[index] = Player(
            color: color,
            role: players[index].role
        )
    }

    private func updatePlayerRole(
        targetID: UInt8,
        value: UInt8
    ) {
        guard let role = Role(bleValue: value) else { return }

        let index = Int(targetID) - 1
        guard index >= 0 else { return }

        ensurePlayerCapacity(through: index)

        // 새 인스턴스로 교체해야 @Observable 배열 변경이 감지됨
        players[index] = Player(
            color: players[index].color,
            role: role
        )
    }

    private func ensurePlayerCapacity(through index: Int) {
        while players.count <= index {
            players.append(Player(color: .pink))
        }
    }
}
