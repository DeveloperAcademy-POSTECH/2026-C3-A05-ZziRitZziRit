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

    /// 자기 자신의 플레이어 번호 (roleResult의 targetID) — 자기 표시/차단용
    var myPlayerNumber: Int = 0

    /// 밤 대기 화면에 표시할 "지금 진행 중인 직업"
    var activeNightRole: Role = .mafia

    /// 현재 페이즈 제한 시간(초) — 선택 화면 진행 바 동기화용
    var phaseSeconds: Int = 0

    /// 최후 변론/찬반 투표/처형 결과의 대상 플레이어 번호
    var defendantNumber: Int = 0

    /// 경찰 수사 결과의 대상 플레이어 번호
    var investigatedNumber: Int = 0

    func player(number: Int) -> Player? {
        guard number >= 1, number <= players.count else { return nil }
        return players[number - 1]
    }

    var defendant: Player? { player(number: defendantNumber) }

    var isMeDefendant: Bool {
        defendantNumber != 0 && defendantNumber == myPlayerNumber
    }

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
            myPlayerNumber = Int(command.targetID)
            currentScreen = .roleResult

        case .dayTime:
            currentScreen = .dayTime

        case .mafiaTurn:
            phaseSeconds = Int(command.value)
            currentScreen = .mafiaTurn

        case .policeTurn:
            phaseSeconds = Int(command.value)
            currentScreen = .policeTurn

        case .doctorTurn:
            phaseSeconds = Int(command.value)
            currentScreen = .doctorTurn

        case .nightWaiting:
            activeNightRole = Role(bleValue: command.value) ?? .mafia
            currentScreen = .nightTime

        case .policeResult:
            policeResultIsMafia = command.value == 1
            investigatedNumber = Int(command.targetID)
            currentScreen = .policeResult

        case .vote:
            phaseSeconds = Int(command.value)
            currentScreen = .vote

        case .finalDefense:
            defendantNumber = Int(command.targetID)
            currentScreen = .finalDefense

        case .executionVote:
            defendantNumber = Int(command.targetID)
            phaseSeconds = Int(command.value)
            currentScreen = .executionVote

        case .executionResult:
            defendantNumber = Int(command.targetID)
            executionResult = command.value == 1 ? .dead : .survive
            currentScreen = .executionResult

        case .playerDied:
            markPlayerDead(targetID: command.targetID)

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
        myPlayerNumber = 0
        activeNightRole = .mafia
        phaseSeconds = 0
        defendantNumber = 0
        investigatedNumber = 0
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

    private func markPlayerDead(targetID: UInt8) {
        let index = Int(targetID) - 1
        guard index >= 0 else { return }

        ensurePlayerCapacity(through: index)

        // 새 인스턴스로 교체해야 @Observable 배열 변경이 감지됨
        players[index] = Player(
            color: players[index].color,
            role: players[index].role,
            isAlive: false
        )
    }

    private func ensurePlayerCapacity(through index: Int) {
        while players.count <= index {
            players.append(Player(color: .pink))
        }
    }
}
