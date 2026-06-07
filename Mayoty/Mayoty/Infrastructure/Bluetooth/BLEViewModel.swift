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
    var answers: [UUID: BLEAnswer] = [:]
    var logs: [String] = []

    private let peripheralManager = iPhoneBLEPeripheralManager()
    private var eventTask: Task<Void, Never>?

    init() {
        observePeripheralEvents()
    }

    deinit {
        eventTask?.cancel()
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

        case let .answerReceived(id, answer):
            receiveAnswer(from: id, answer: answer)

        case let .log(text):
            addLog(text)
        }
    }

    func receiveAnswer(from id: UUID, answer: BLEAnswer) {
        answers[id] = answer
        logs.insert(
            "\(id.uuidString.prefix(8)) → \(answer.kind), value: \(answer.value)",
            at: 0
        )
    }

    private func addLog(_ text: String) {
        logs.insert(text, at: 0)
    }
}
