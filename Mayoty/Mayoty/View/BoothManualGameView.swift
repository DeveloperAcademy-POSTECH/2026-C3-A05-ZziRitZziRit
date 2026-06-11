//
//  BoothManualGameView.swift
//  Mayoty
//
//  Created by sun on 6/11/26.
//

import SwiftUI
import AVFoundation
import AVKit

struct BoothManualGameView: View {

    private let peripheralManager: iPhoneBLEPeripheralManager
    private let watchCommandManager: WatchCommandManager

    @State private var game: MafiaGame
    @State private var isControlSheetPresented = false

    init() {
        let peripheralManager = iPhoneBLEPeripheralManager()
        let watchCommandManager = WatchCommandManager(
            peripheralManager: peripheralManager
        )

        self.peripheralManager = peripheralManager
        self.watchCommandManager = watchCommandManager

        _game = State(initialValue: MafiaGame(
            players: [
                Player(id: UUID(), watchId: "booth-1"),
                Player(id: UUID(), watchId: "booth-2"),
                Player(id: UUID(), watchId: "booth-3"),
                Player(id: UUID(), watchId: "booth-4"),
                Player(id: UUID(), watchId: "booth-5")
            ],
            initialState: WaitingState(),
            homeKitLightManager: HomeKitLightManager(),
            watchCommandManager: watchCommandManager
        ))
    }

    var body: some View {
        AirPlayRoutePicker()
            .frame(width: 60, height: 60)
            .padding(.top, 10)
        
        VStack(spacing: 0) {
            header

            Divider()

            stateContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                isControlSheetPresented = true
            } label: {
                Text("상태 변경")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.thinMaterial)
        }
        .sheet(isPresented: $isControlSheetPresented) {
            controlSheet
                .presentationDetents([.height(320), .medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("부스 운영 모드")
                .font(.title2.bold())
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var controlSheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("상태 변경")
                    .font(.title3.bold())
                    .padding(.horizontal)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    boothButton("대기") {
                        game.changeState(to: WaitingState())
                    }

                    boothButton("역할 배정") {
                        game.changeState(to: RoleAssigningState())
                    }

                    boothButton("소개") {
                        game.changeState(to: IntroductionState())
                    }

                    boothButton("마피아") {
                        game.changeState(to: MafiaState())
                    }

                    boothButton("경찰") {
                        game.changeState(to: PoliceState())
                    }

                    boothButton("의사") {
                        game.changeState(to: DoctorState())
                    }

                    boothButton("토론") {
                        game.changeState(to: DiscussionState())
                    }

                    boothButton("투표") {
                        game.changeState(to: VoteState())
                    }

                    boothButton("최후 변론") {
                        game.selectFinalDefensePlayer(game.players[0])
                        game.changeState(to: FinalDefenseState())
                    }

                    boothButton("처형 투표") {
                        game.selectFinalDefensePlayer(game.players[0])
                        game.changeState(to: ExecutionVoteState())
                    }

                    boothButton("처형 결과") {
                        game.selectFinalDefensePlayer(game.players[0])
                        game.changeState(to: ExecutionResultState())
                    }

                    boothButton("시민 승리") {
                        game.setWinner(.citizens)
                        game.changeState(to: ResultState())
                    }

                    boothButton("마피아 승리") {
                        game.setWinner(.mafia)
                        game.changeState(to: ResultState())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
    }

    private func boothButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
            isControlSheetPresented = false
        } label: {
            Text(title)
                .font(.caption.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.borderedProminent)
    }

    @ViewBuilder
    private var stateContent: some View {
        switch game.currentState {

        case is WaitingState:
            WaitingStateView(
                players: game.players,
                remainingTime: game.timerManager.remainingTime
            )

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
            GameResultView(
                winner: game.winner ?? .citizens
            )

        default:
            Text("알 수 없는 상태")
        }
    }
}
 
