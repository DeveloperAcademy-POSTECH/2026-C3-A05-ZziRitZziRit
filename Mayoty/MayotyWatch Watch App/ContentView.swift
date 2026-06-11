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
            JoinGameView(viewModel: viewModel)
            
        case .roleAssigning:
            RoleAssigningView()
            
        case .roleResult:
            RoleSelectingView(
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
                excutionResult: .survive
            )
            
        case .gameEnded:
            VictoryView(
                victory: viewModel.commandStore.winner == .mafia
                    ? .mafia
                    : .citizen
            )
        }
    }
}
