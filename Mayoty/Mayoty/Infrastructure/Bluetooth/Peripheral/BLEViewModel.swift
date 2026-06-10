//
//  BLEViewModel.swift
//  Mayoty
//
//  Created by sun on 6/7/26.
//

import Foundation
import Observation

@Observable
final class BLEViewModel {
    var isAdvertising: Bool = false
    var bluetoothStateText: String = "Unknown"
    var connectedWatchIDs: Set<UUID> = []
    var answers: [UUID: BLEAnswer] = [:]
    var logs: [String] = []

    var game: MafiaGame

    private let peripheralManager = iPhoneBLEPeripheralManager()
    private var eventTask: Task<Void, Never>?

    init(game: MafiaGame) {
        self.game = game
        observePeripheralEvents()
    }

    deinit {
        eventTask?.cancel()
    }

    func startAdvertising() {
        peripheralManager.startAdvertising()
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }

    private func observePeripheralEvents() {
        eventTask = Task {
            for await event in peripheralManager.events {
                await MainActor.run {
                    self.handle(event)
                }
            }
        }
    }

    private func handle(_ event: BLEPeripheralEvent) {
        switch event {
        case let .bluetoothStateChanged(stateText, log):
            bluetoothStateText = stateText

            if let log {
                addLog(log)
            }

        case let .advertisingChanged(isAdvertising, log):
            self.isAdvertising = isAdvertising
            addLog(log)

        case let .watchConnected(id):
            connectedWatchIDs.insert(id)
            addLog("Watch connected: \(id.uuidString.prefix(8))")

        case let .answerReceived(id, answer):
            receiveAnswer(from: id, answer: answer)

        case let .log(text):
            addLog(text)
        }
    }

    func receiveAnswer(from id: UUID, answer: BLEAnswer) {
        connectedWatchIDs.insert(id)
        answers[id] = answer

        logs.insert(
            "\(id.uuidString.prefix(8)) → \(answer.kind), value: \(answer.value)",
            at: 0
        )

        handleGameAnswer(from: id, answer: answer)
    }

    private func handleGameAnswer(from id: UUID, answer: BLEAnswer) {
        switch answer.kind {
        case .join:
            break

        case .mafiaSelected:
            guard let target = player(for: answer.value) else { return }
            game.handleAction(.mafiaSelected(target: target))

        case .policeSelected:
            guard let target = player(for: answer.value) else { return }
            game.handleAction(.policeSelected(target: target))

        case .doctorSelected:
            guard let target = player(for: answer.value) else { return }
            game.handleAction(.doctorSelected(target: target))

        case .voteSubmitted:
            guard let voter = player(for: id) else { return }
            guard let target = player(for: answer.value) else { return }
            game.handleAction(.voteSubmitted(voter: voter, target: target))

        case .executionVoteSubmitted:
            guard let voter = player(for: id) else { return }
            game.handleAction(
                .executionVoteSubmitted(
                    voter: voter,
                    isAgree: answer.value == 1
                )
            )
        }
    }

    private func player(for number: UInt8) -> Player? {
        let index = Int(number) - 1

        guard game.players.indices.contains(index) else {
            addLog("Invalid player number: \(number)")
            return nil
        }

        return game.players[index]
    }

    private func player(for watchID: UUID) -> Player? {
        game.players.first { player in
            player.watchId == watchID.uuidString
        }
    }

    private func addLog(_ text: String) {
        logs.insert(text, at: 0)
    }
}

