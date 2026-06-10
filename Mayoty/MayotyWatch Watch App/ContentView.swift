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
            RoleNightView(role: .mafia)
            
        case .policeTurn:
            RoleNightView(role: .police)
            
        case .doctorTurn:
            RoleNightView(role: .doctor)
            
        case .nightTime:
            RoleSelectingView(role: viewModel.commandStore.role)
            
        case .policeResult:
            PoliceArrestResultView(
                result: viewModel.commandStore.policeResultIsMafia
                ? .success
                : .fail
            )
            
        case .vote:
            RoleNightView(role: .citizen)
            
        case .finalDefense:
            FinalDefenseView()
            
        case .executionVote:
            ExecutionVoteView()
            
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
