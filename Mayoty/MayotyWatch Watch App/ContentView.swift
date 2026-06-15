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
        switch viewModel.currentScreen {
        case .join:
            JoinGameView(viewModel: viewModel)
            
        case .connectionSucceeded:
            ConnectionSucceedView(viewModel: viewModel)

        case .waiting:
            WaitingPlayersView(viewModel: viewModel)
            
        case .roleAssigning:
            RoleAssigningView(viewModel: viewModel)
            
        case .roleResult:
            RoleResultView(viewModel: viewModel)
            
        case .introductino:
            DayTimeView(viewModel: viewModel)
            
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
            
        case .dayTime:
            DayTimeView(viewModel: viewModel)

        case .vote:
            RoleNightView(
                role: .citizen,
                viewModel: viewModel
            )
            
        case .nightTime:
            RoleSelectingView(
                role: .mafia,
                viewModel: viewModel
            )
            
        case .policeResult:
            PoliceArrestResultView(
                result: viewModel.commandStore.policeResultIsMafia ? .success : .fail,
                viewModel: viewModel
            )
            
        case .finalDefense:
            FinalDefenseView(viewModel: viewModel)
            
        case .executionVote:
            ExecutionVoteView(
                viewModel: viewModel
            )
            
        case .executionResult:
            ExecutionResultView(
                excutionResult: .survive,
                viewModel: viewModel
            )
            
        case .gameEnded:
            VictoryView(
                victory: viewModel.commandStore.winner == .mafia
                    ? .mafia
                    : .citizen,
                viewModel: viewModel
            )
        }
    }
}
