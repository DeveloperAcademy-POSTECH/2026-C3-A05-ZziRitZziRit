//
//  GameView.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import SwiftUI

struct GameView: View {

    @State private var bleModel = BLEViewModel()

    @State private var game = MafiaGame(
        players: [],
        initialState: WaitingState(),
        homeKitLightManager: HomeKitLightManager()
    )

    private var connectedPlayers: [Player] {
        bleModel.connectedWatchIDs.map { id in
            Player(
                id: id,
                watchId: id.uuidString
            )
        }
    }

    private var canStartGame: Bool {
        connectedPlayers.count >= 2
    }

    var body: some View {
        switch game.currentState {

        case is WaitingState:
            VStack {
                WaitingStateView(
                    players: connectedPlayers,
                    remainingTime: game.timerManager.remainingTime
                )

                Button("게임 시작") {
                    guard canStartGame else { return }

                    game = MafiaGame(
                        players: connectedPlayers,
                        initialState: WaitingState(),
                        homeKitLightManager: HomeKitLightManager()
                    )

                    game.handleAction(.startGame)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canStartGame)
                .padding(.bottom)

                if !canStartGame {
                    
                    // TODO: 기기 5대 이상 연결해야 넘어갈 수 있도록 수정 예정
                    Text("최소 2명 이상의 플레이어가 연결되어야 시작할 수 있습니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

        case is RoleAssigningState:
            RoleAssignView(
                players: game.players,
                remainingTime: game.timerManager.remainingTime
            )

        case is IntroductionState:
            DiscussionStateView(
                players: game.players,
                title: "IntroductionState",
                remainingTime: game.timerManager.remainingTime
            )

        case is MafiaState:
            NightActionStateView(
                players: game.players,
                title: "MafiaState",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.mafiaTarget
            ) { player in
                game.handleAction(.mafiaSelected(target: player))
            }

        case is PoliceState:
            NightActionStateView(
                players: game.players,
                title: "PoliceState",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.policeTarget
            ) { player in
                game.handleAction(.policeSelected(target: player))
            }

        case is DoctorState:
            NightActionStateView(
                players: game.players,
                title: "DoctorState",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.doctorTarget
            ) { player in
                game.handleAction(.doctorSelected(target: player))
            }

        case is DiscussionState:
            DiscussionStateView(
                players: game.players,
                title: "DiscussionState",
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
                finalDefender: nil,
                remainingTime: game.timerManager.remainingTime,
                stateTitle: "FinalDefenseState"
            )

        case is ExecutionVoteState:
            ExecutionVoteView(
                players: game.players,
                finalDefender: nil,
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
                finalDefender: nil,
                remainingTime: game.timerManager.remainingTime,
                stateTitle: "ExecutionResultState"
            )

        case is ResultState:
            if let winner = game.winner {
                GameResultView(winner: winner)
            }

        default:
            Text("알 수 없는 상태")
        }
    }
}
