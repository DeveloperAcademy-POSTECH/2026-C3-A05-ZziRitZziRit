//
//  GameView.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import SwiftUI

struct GameView: View {

    let dependencies: AppDependencies

    @State private var didAutoStartGame = false

    private var bleViewModel: BLEViewModel {
        dependencies.bleViewModel
    }

    private var game: MafiaGame {
        dependencies.bleViewModel.game
    }

    private var connectedPlayers: [Player] {
        bleViewModel.connectedPlayers
    }

    private var canStartGame: Bool {
        connectedPlayers.count == GameRule.requiredPlayerCount
    }

    private func startGameIfNeeded() {
        guard canStartGame else { return }
        guard game.currentState is WaitingState else { return }
        guard !didAutoStartGame else { return }

        didAutoStartGame = true

        let newGame = MafiaGame(
            players: connectedPlayers,
            initialState: WaitingState(),
            homeKitLightManager: dependencies.homeKitLightManager,
            watchCommandManager: dependencies.watchCommandManager
        )

        bleViewModel.game = newGame

        newGame.handleAction(.startGame)
    }

    /// 게임 종료 후 새 로비로 복귀 — 연결된 워치가 그대로면 자동으로 다음 판 시작
    private func restartGame() {
        game.handleAction(.gameEnded)

        let lobbyGame = MafiaGame(
            players: [],
            initialState: WaitingState(),
            homeKitLightManager: dependencies.homeKitLightManager,
            watchCommandManager: dependencies.watchCommandManager
        )

        bleViewModel.game = lobbyGame
        didAutoStartGame = false

        // 워치들을 대기 화면으로 복귀시킴 (gameEnded 화면에서 waitingPlayers 수신 시 복귀)
        dependencies.watchCommandManager.sendWaitingPlayers(
            count: connectedPlayers.count
        )
    }

    var body: some View {
        switch game.currentState {

        case is WaitingState:
            VStack {
                WaitingStateView(
                    players: connectedPlayers,
                    remainingTime: game.timerManager.remainingTime
                )

                Text("플레이어를 기다리는 중... (\(connectedPlayers.count)/\(GameRule.requiredPlayerCount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .onAppear {
                // BLE/HomeKit 시스템 연결은 기존 코드처럼 첫 렌더 시점에 시작
                dependencies.activate()
                startGameIfNeeded()
            }
            .onChange(of: connectedPlayers.count) {
                // 시작 전 이탈 시 자동 시작 잠금 해제 — 재충원되면 다시 시작 가능
                if connectedPlayers.count < GameRule.requiredPlayerCount,
                   game.players.isEmpty {
                    didAutoStartGame = false
                }

                startGameIfNeeded()
            }

        case is RoleAssigningState:
            RoleAssignView(
                players: game.players,
                remainingTime: game.timerManager.remainingTime
            )

        case is IntroductionState:
            DiscussionStateView(
                players: game.players,
                title: "자기소개",
                remainingTime: game.timerManager.remainingTime
            )

        case is MafiaState:
            NightActionStateView(
                players: game.players,
                title: "마피아의 밤",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.mafiaTarget
            ) { player in
                game.handleAction(.mafiaSelected(target: player))
            }

        case is PoliceState:
            NightActionStateView(
                players: game.players,
                title: "경찰의 밤",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.policeTarget
            ) { player in
                game.handleAction(.policeSelected(target: player))
            }

        case is DoctorState:
            NightActionStateView(
                players: game.players,
                title: "의사의 밤",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.doctorTarget
            ) { player in
                game.handleAction(.doctorSelected(target: player))
            }

        case is DiscussionState:
            DiscussionStateView(
                players: game.players,
                title: "자유 토론",
                remainingTime: game.timerManager.remainingTime
            )

        case is VoteState:
            VoteStateView(
                players: game.players,
                remainingTime: game.timerManager.remainingTime
            ) { voter, target in
                game.handleAction(
                    .voteSubmitted(
                        voter: voter,
                        target: target
                    )
                )
            }

        case is FinalDefenseState:
            FinalDefenseView(
                players: game.players,
                finalDefender: game.finalDefensePlayer,
                remainingTime: game.timerManager.remainingTime,
                stateTitle: "최후 변론"
            )

        case is ExecutionVoteState:
            ExecutionVoteView(
                players: game.players,
                finalDefender: game.finalDefensePlayer,
                remainingTime: game.timerManager.remainingTime
            ) { voter, isAgree in
                game.handleAction(
                    .executionVoteSubmitted(
                        voter: voter,
                        isAgree: isAgree
                    )
                )
            }

        case is ExecutionResultState:
            FinalDefenseView(
                players: game.players,
                finalDefender: game.finalDefensePlayer,
                remainingTime: game.timerManager.remainingTime,
                stateTitle: "처형 결과"
            )

        case is ResultState:
            if let winner = game.winner {
                GameResultView(winner: winner) {
                    restartGame()
                }
            } else {
                ContentUnavailableView(
                    "결과 집계 중",
                    systemImage: "hourglass"
                )
            }

        default:
            Text("알 수 없는 상태")
        }
    }
}
