//
//  DiscussionState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct DiscussionState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("☀️ 토론 시작")

        game.watchCommandManager.sendDayTime()

        game.lightManager.setPlayerColorScene(
            players: game.players
        )

        game.soundManager.playDiscussionStartSound(game: game)

        game.timerManager.startTimer(
            seconds: GameTime.discussion,
            onTimeout: {
                GameLogger.timer("토론 시간 종료")
                game.changeState(to: VoteState())
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .discussionEnded = action else {
            return
        }

        GameLogger.event("☀️ 토론 종료")

        game.changeState(to: VoteState())
    }

    func exit(game: MafiaGame) {
        GameLogger.event("☀️ 토론 상태 종료")
        game.timerManager.stopTimer()
    }
}
