//
//  ContentView.swift
//  MayotyWatch Watch App
//
//  Created by sun on 5/31/26.
//

import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: WatchViewModel
    
    var body: some View {
        switch viewModel.commandStore.currentScreen {
        case .join:
            // BLE 연결 실패 시 재시도 화면으로 안내
            if viewModel.connectionState == .failed {
                ConnectionFailView {
                    viewModel.scan()
                }
            } else {
                JoinGameView(viewModel: viewModel)
            }

        case .connectionSucceeded:
            ConnectionSucceedView()

        case .connectionFailed:
            ConnectionFailView {
                viewModel.scan()
            }

        case .waiting:
            WaitingPlayersView(
                count: viewModel.commandStore.waitingCount
            )
            
        case .roleAssigning:
            RoleAssigningView()
            
        case .roleResult:
            RoleResultView(
                role: viewModel.commandStore.role
            )
            
        case .dayTime:
            DayTimeView()
            
        case .mafiaTurn:
            RoleNightView(
                role: .mafia,
                viewModel: viewModel
            )

        case .policeTurn:
            RoleNightView(
                role: .police,
                viewModel: viewModel
            )

        case .doctorTurn:
            RoleNightView(
                role: .doctor,
                viewModel: viewModel
            )

        case .vote:
            RoleNightView(
                role: .citizen,
                viewModel: viewModel
            )
            
        case .nightTime:
            RoleSelectingView(role: viewModel.commandStore.role)
            
        case .policeResult:
            PoliceArrestResultView(
                result: viewModel.commandStore.policeResultIsMafia
                ? .success
                : .fail
            )
            
        case .finalDefense:
            FinalDefenseView()
            
        case .executionVote:
            ExecutionVoteView(
                viewModel: viewModel
            )
            
        case .executionResult:
            ExecutionResultView(
                excutionResult: viewModel.commandStore.executionResult
            )
            
        case .gameEnded:
            VictoryView(
                victory: viewModel.commandStore.winner == .mafia
                    ? .mafia
                    : .citizen
            ) {
                viewModel.commandStore.returnToWaiting()
            }

        case .dead:
            DeadPlayerFlowView(
                players: viewModel.commandStore.players
            )
        }
    }
}
