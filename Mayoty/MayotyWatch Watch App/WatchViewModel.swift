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
    
    private let centralManager = WatchCentralManager()
    private var eventTask: Task<Void, Never>?

    init() {
        observeEvents()
    }

    deinit {
        eventTask?.cancel()
    }

    func scan() {
        centralManager.scan()
    }
    
    func disconnect() {
        centralManager.disconnect()
    }

    func send(_ answer: BLEAnswer) {
        centralManager.send(answer)
    }

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
