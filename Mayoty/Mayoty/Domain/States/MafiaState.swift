//
//  MafiaState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct MafiaState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🦹‍♂️ 마피아 선택 시작")

        game.watchCommandManager.sendMafiaTurn(
            to: game.players
        )

        game.soundManager.playMafiaStartSound()

        game.timerManager.startTimer(
            seconds: GameTime.mafia,
            onTimeout: {
                transitionToPolice(game: game)
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .mafiaSelected(let target) = action else { return }

        GameLogger.action(action)
        GameLogger.event(
            "🦹‍♂️ 마피아 타겟 선택 완료: \(target.color?.rawValue ?? "색상 없음")"
        )

        game.selectMafiaTarget(target)
        transitionToPolice(game: game)
    }

    func exit(game: MafiaGame) {
        GameLogger.event("🦹‍♂️ 마피아 선택 종료")

        game.timerManager.stopTimer()
    }

    private func transitionToPolice(game: MafiaGame) {
        game.timerManager.stopTimer()

        Task { @MainActor in
            await game.soundManager.playMafiaEndSoundAndWait()
            game.changeState(to: PoliceState())
        }
    }
}
