//
//  WatchViewModel.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//

import Foundation
import Observation

@Observable
final class WatchViewModel {

    var connectionState: WatchConnectionState = .idle

    let commandStore = WatchCommandStore()

    private let centralManager: WatchCentralManager
    private var eventTask: Task<Void, Never>?
    private var autoNextTask: Task<Void, Never>?

    private let screenFlow: [WatchScreen] = [
        .join,
        .connectionSucceeded,
        .waiting,
        .roleAssigning,
        .roleResult,
        .dayTime,
        .nightTime,
        .mafiaTurn,
        .policeTurn,
        .policeResult,
        .doctorTurn,
        .vote,
        .finalDefense,
        .executionVote,
        .executionResult,
        .gameEnded
    ]

    init() {
        self.centralManager = WatchCentralManager(
            commandStore: commandStore
        )

        observeEvents()
    }

    deinit {
        eventTask?.cancel()
        autoNextTask?.cancel()
    }

    var currentScreen: WatchScreen {
        commandStore.currentScreen
    }

    @MainActor
    func goNext() {
        guard let currentIndex = screenFlow.firstIndex(of: commandStore.currentScreen),
              currentIndex < screenFlow.count - 1
        else { return }

        commandStore.currentScreen = screenFlow[currentIndex + 1]
    }
    
    @MainActor
    func resetGame() {
        autoNextTask?.cancel()

        commandStore.players.removeAll()
        commandStore.role = .citizen
        commandStore.policeResultIsMafia = false
        commandStore.winner = .citizens
        commandStore.currentScreen = .join
    }

    func autoNext(after seconds: Double = 2.0) {
        autoNextTask?.cancel()

        autoNextTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(seconds))
            goNext()
        }
    }

    // MARK: - 연결 관리

    func scan() {
        centralManager.scan()
    }

    func disconnect() {
        centralManager.disconnect()
    }

    // MARK: - 밤 행동

    func selectMafiaTarget(playerID: UInt8) {
        send(.mafiaSelected(playerID: playerID))
        goNext()
    }

    func selectPoliceTarget(playerID: UInt8) {
        send(.policeSelected(playerID: playerID))
        goNext()
    }

    func selectDoctorTarget(playerID: UInt8) {
        send(.doctorSelected(playerID: playerID))
        goNext()
    }

    // MARK: - 투표 행동

    func submitVote(targetID: UInt8) {
        send(.voteSubmitted(targetID: targetID))
        goNext()
    }

    func submitExecutionVote(isAgree: Bool) {
        send(.executionVoteSubmitted(isAgree: isAgree))
        goNext()
    }

    // MARK: - 응답 전송

    private func send(_ answer: BLEAnswer) {
        centralManager.send(answer)
    }

    // MARK: - 이벤트 관찰

    private func observeEvents() {
        eventTask = Task {
            for await state in centralManager.events {
                await MainActor.run {
                    self.connectionState = state
                }
            }
        }
    }
}
