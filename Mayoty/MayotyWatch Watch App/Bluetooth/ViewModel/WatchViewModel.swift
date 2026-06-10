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

    init() {
        self.centralManager = WatchCentralManager(
            commandStore: commandStore
        )

        observeEvents()
    }

    deinit {
        eventTask?.cancel()
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
    }

    func selectPoliceTarget(playerID: UInt8) {
        send(.policeSelected(playerID: playerID))
    }

    func selectDoctorTarget(playerID: UInt8) {
        send(.doctorSelected(playerID: playerID))
    }

    // MARK: - 투표 행동

    func submitVote(targetID: UInt8) {
        send(.voteSubmitted(targetID: targetID))
    }

    func submitExecutionVote(isAgree: Bool) {
        send(.executionVoteSubmitted(isAgree: isAgree))
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
