//
//  DemoAutoPlay.swift
//  MayotyWatch Watch App
//
//  Created by Claude on 6/11/26.
//

#if DEBUG
import Foundation

/// 시뮬레이터 데모용 오토플레이 봇 (-autoplay 런치 인자)
///
/// 시뮬레이터는 터치 자동화가 어려우므로, 행동 화면에 진입하면
/// 사람처럼 몇 초 고민한 뒤 무작위로 지목/투표한다.
/// 처형 찬반은 항상 찬성 — 게임이 승부까지 수렴하도록.
@MainActor
enum DemoAutoPlay {

    private static var task: Task<Void, Never>?

    static func startIfNeeded(viewModel: WatchViewModel) {
        guard ProcessInfo.processInfo.arguments.contains("-autoplay") else { return }
        guard task == nil else { return }

        GameLogger.bluetooth("[autoplay] 오토플레이 시작")

        task = Task {
            await run(viewModel: viewModel)
        }
    }

    private static func run(viewModel: WatchViewModel) async {
        var lastHandled: WatchScreen?

        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(500))

            let screen = viewModel.commandStore.currentScreen
            guard screen != lastHandled else { continue }
            lastHandled = screen

            guard isActionable(screen) else { continue }

            // 사람처럼 2.5~5초 고민
            try? await Task.sleep(for: .seconds(Double.random(in: 2.5...5)))

            // 고민하는 사이 페이즈가 지나갔으면 보내지 않음
            guard viewModel.commandStore.currentScreen == screen else { continue }

            act(on: screen, viewModel: viewModel)
        }
    }

    private static func isActionable(_ screen: WatchScreen) -> Bool {
        switch screen {
        case .mafiaTurn, .policeTurn, .doctorTurn, .vote, .executionVote:
            return true
        default:
            return false
        }
    }

    /// 생존자 중에서 대상 선택 (투표는 자기 자신 제외 — iPhone이 거부함)
    private static func pickTarget(
        viewModel: WatchViewModel,
        excludeSelf: Bool
    ) -> UInt8 {
        let store = viewModel.commandStore
        var candidates: [UInt8] = []

        for (index, player) in store.players.enumerated() where player.isAlive {
            let number = UInt8(index + 1)
            if excludeSelf, Int(number) == store.myPlayerNumber { continue }
            candidates.append(number)
        }

        return candidates.randomElement() ?? UInt8.random(in: 1...5)
    }

    private static func act(on screen: WatchScreen, viewModel: WatchViewModel) {
        let target = pickTarget(
            viewModel: viewModel,
            excludeSelf: screen == .vote
        )

        switch screen {
        case .mafiaTurn:
            GameLogger.bluetooth("[autoplay] 마피아 지목 → \(target)")
            viewModel.selectMafiaTarget(playerID: target)

        case .policeTurn:
            GameLogger.bluetooth("[autoplay] 경찰 수사 → \(target)")
            viewModel.selectPoliceTarget(playerID: target)

        case .doctorTurn:
            GameLogger.bluetooth("[autoplay] 의사 치료 → \(target)")
            viewModel.selectDoctorTarget(playerID: target)

        case .vote:
            GameLogger.bluetooth("[autoplay] 투표 → \(target)")
            viewModel.submitVote(targetID: target)

        case .executionVote:
            GameLogger.bluetooth("[autoplay] 처형 찬성")
            viewModel.submitExecutionVote(isAgree: true)

        default:
            break
        }
    }
}
#endif
