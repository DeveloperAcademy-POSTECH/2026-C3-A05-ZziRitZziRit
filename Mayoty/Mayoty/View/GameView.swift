//
//  GameView.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import SwiftUI

struct GameView: View {
    
    // TODO: Bluetooth 연결 구현 후 목데이터 제거 예정
    @State private var game = MafiaGame(
        players: [
            Player(),
            Player(),
            Player(),
            Player(),
            Player()
        ],
        initialState: WaitingState(),
        homeKitLightManager:  HomeKitLightManager()
    )

    var body: some View {
        switch game.currentState {
        case is WaitingState:
            VStack {
                WaitingStateView(
                    players: game.players,
                    remainingTime: game.timerManager.remainingTime
                )

                Button("게임 시작") {
                    game.handleAction(.startGame)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
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
                game.selectMafiaTarget(player)
            }

        case is PoliceState:
            NightActionStateView(
                players: game.players,
                title: "PoliceState",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.policeTarget
            ) { player in
                game.selectInvestigateTarget(player)
            }

        case is DoctorState:
            NightActionStateView(
                players: game.players,
                title: "DoctorState",
                remainingTime: game.timerManager.remainingTime,
                selectedPlayer: game.doctorTarget
            ) { player in
                game.selectHealTarget(player)
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
            )
            
        case is FinalDefenseState:
            FinalDefenseView(
                players: game.players,
                finalDefender: nil,
                remainingTime: game.timerManager.remainingTime
            )
            
        case is ExecutionVoteState:
            ExecutionVoteView(
                players: game.players,
                finalDefender: nil,
                remainingTime: game.timerManager.remainingTime
            )
            
        default:
            Text("TODO: \(String(describing: type(of: game.currentState)))")
        }
    }
}

