//
//  GameView.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import SwiftUI

struct GameView: View {
    
    @State private var game: MafiaGame
    @State private var bleViewModel: BLEViewModel
    @State private var didAutoStartGame = false

    private let peripheralManager: iPhoneBLEPeripheralManager
    private let watchCommandManager: WatchCommandManager
    
    init() {
        let peripheralManager = iPhoneBLEPeripheralManager()

        let watchCommandManager = WatchCommandManager(
            peripheralManager: peripheralManager
        )

        let initialGame = MafiaGame(
            players: [],
            initialState: WaitingState(),
            homeKitLightManager: HomeKitLightManager(),
            watchCommandManager: watchCommandManager
        )
        
        self.peripheralManager = peripheralManager
        self.watchCommandManager = watchCommandManager

        _game = State(initialValue: initialGame)
        _bleViewModel = State(
            initialValue: BLEViewModel(
                game: initialGame,
                peripheralManager: peripheralManager
            )
        )
    }
    
        private var connectedPlayers: [Player] {
            bleViewModel.connectedWatchIDs.map { id in
                Player(
                    id: id,
                    watchId: id.uuidString
                )
            }
        }
    
//    private var connectedPlayers: [Player] {
//        [
//            Player(id: UUID(), watchId: "mock-watch-1"),
//            Player(id: UUID(), watchId: "mock-watch-2"),
//            Player(id: UUID(), watchId: "mock-watch-3"),
//            Player(id: UUID(), watchId: "mock-watch-4")
//            Player(id: UUID(), watchId: "mock-watch-5")
//        ]
//    }
    
    private var canStartGame: Bool {
        connectedPlayers.count >= 3
    }
    
    private func startGameIfNeeded() {
        guard canStartGame else { return }
        guard game.currentState is WaitingState else { return }
        guard !didAutoStartGame else { return }
        
        didAutoStartGame = true
        
        game = MafiaGame(
            players: connectedPlayers,
            initialState: WaitingState(),
            homeKitLightManager: HomeKitLightManager(),
            watchCommandManager: watchCommandManager
        )
        
        game.handleAction(.startGame)
    }
    
    var body: some View {
        switch game.currentState {
            
        case is WaitingState:
            VStack {
                WaitingStateView(
                    players: connectedPlayers,
                    remainingTime: game.timerManager.remainingTime
                )
                
                Text("플레이어를 기다리는 중...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .onAppear {
                startGameIfNeeded()
            }
            .onChange(of: connectedPlayers.count) {
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
                finalDefender: game.finalDefensePlayer,
                remainingTime: game.timerManager.remainingTime,
                stateTitle: "FinalDefenseState"
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
