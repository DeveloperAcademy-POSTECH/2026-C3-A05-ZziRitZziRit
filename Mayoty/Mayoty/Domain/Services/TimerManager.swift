//
//  TimerManager.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

import Foundation

final class TimerManager {
    private var timer: Timer?
    private(set) var remainingTime: Int = 0

    func startTimer(
        seconds: Int,
        onTick: ((Int) -> Void)? = nil,
        onTimeout: @escaping () -> Void
    ) {
        stopTimer()

        remainingTime = seconds
        onTick?(remainingTime)

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] timer in
            guard let self else { return }

            self.remainingTime -= 1
            onTick?(self.remainingTime)

            if self.remainingTime <= 0 {
                timer.invalidate()
                self.timer = nil
                onTimeout()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        remainingTime = 0
    }
}
