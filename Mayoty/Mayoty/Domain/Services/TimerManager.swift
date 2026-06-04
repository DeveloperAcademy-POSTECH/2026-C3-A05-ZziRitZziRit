//
//  TimerManager.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

import Foundation

final class TimerManager {
    private var timerTask: Task<Void, Never>?
    private let clock = ContinuousClock()

    private(set) var remainingTime: Int = 0

    func startTimer(
        seconds: Int,
        onTick: ((Int) -> Void)? = nil,
        onTimeout: @escaping () -> Void
    ) {
        stopTimer()

        let deadline = clock.now + .seconds(seconds)

        remainingTime = seconds
        onTick?(remainingTime)

        timerTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                do {
                    try await Task.sleep(
                        for: .milliseconds(200),
                        tolerance: .milliseconds(50),
                        clock: self.clock
                    )
                } catch {
                    return
                }

                let remainingDuration = self.clock.now.duration(to: deadline)
                let remainingSeconds = max(
                    0,
                    Int(remainingDuration.components.seconds)
                )

                await MainActor.run {
                    self.remainingTime = remainingSeconds
                    onTick?(remainingSeconds)
                }

                if remainingSeconds <= 0 {
                    await MainActor.run {
                        self.timerTask = nil
                        onTimeout()
                    }
                    return
                }
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func resetTimer() {
        stopTimer()
        remainingTime = 0
    }
}
