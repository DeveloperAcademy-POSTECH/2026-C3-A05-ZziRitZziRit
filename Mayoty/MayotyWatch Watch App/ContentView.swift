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
            MafNightView(
                players: viewModel.commandStore.players,
                viewModel: viewModel
            )
            
        case .policeTurn:
            PolNightView()
            
        case .doctorTurn:
            DocNightView()
            
        case .nightTime:
            RoleSelectingView(role: viewModel.commandStore.role)
            
        case .policeResult:
            PoliceArrestResultView(
                result: viewModel.commandStore.policeResultIsMafia
                ? .success
                : .fail
            )
            
        case .vote:
            PolNightView()
            
        case .finalDefense:
            FinalDefensementView()
            
        case .executionVote:
            ExecutionVoteView()
            
        case .executionResult:
            ExecutionResultView(
                excutionResult: .survive
            )
            
        case .gameEnded:
            if viewModel.commandStore.winner == .mafia {
                MafiaVictoryView()
            } else {
                CitizenVictoryView()
            }
        }
    }
}
