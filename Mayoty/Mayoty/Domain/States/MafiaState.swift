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
                game.changeState(to: PoliceState())
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
        game.changeState(to: PoliceState())
    }

    func exit(game: MafiaGame) {
        GameLogger.event("🦹‍♂️ 마피아 선택 종료")

        game.soundManager.playMafiaEndSound()
        game.soundManager.stopAll()
        game.timerManager.stopTimer()
    }
}
