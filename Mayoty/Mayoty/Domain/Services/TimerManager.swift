//
//  TimerManager.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

import Foundation
import SwiftUI

@Observable
final class TimerManager {
    private var timerTask: Task<Void, Never>?
    private let clock = ContinuousClock()

    private(set) var remainingTime: Int = 0

    deinit {
        timerTask?.cancel()
    }

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

                // 만료는 deadline 기준, 표시는 올림 — 내림 절삭으로 1초 일찍 끝나는 것 방지
                let isExpired = self.clock.now >= deadline

                let remainingDuration = self.clock.now.duration(to: deadline)
                let remainingFraction = Double(remainingDuration.components.seconds)
                    + Double(remainingDuration.components.attoseconds) / 1e18
                let remainingSeconds = max(0, Int(remainingFraction.rounded(.up)))

                await MainActor.run {
                    // 값이 바뀔 때만 갱신 — @Observable은 동일 값 대입에도 뷰를 무효화함
                    if self.remainingTime != remainingSeconds {
                        self.remainingTime = remainingSeconds
                        onTick?(remainingSeconds)
                    }
                }

                if isExpired {
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
