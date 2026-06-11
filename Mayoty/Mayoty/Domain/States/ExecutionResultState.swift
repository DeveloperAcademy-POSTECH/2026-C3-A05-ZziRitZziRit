//
//  ExecutionResultState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ExecutionResultState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🫠 처형 결과 발표 시작")

        guard let finalDefensePlayer = game.finalDefensePlayer else {
            GameLogger.event("⚠️ 최후 변론자 없음 — 토론으로 복귀")
            game.changeState(to: DiscussionState())
            return
        }

        game.watchCommandManager.sendExecutionResult(
            didExecute: game.voteManager.shouldBeExecuted,
            to: game.players
        )

        game.soundManager.playExecutionResultSound(game: game)

        if game.voteManager.shouldBeExecuted {
            game.soundManager.playGunSoundEffect()
        }

        game.lightManager.setFinalDefenseScene(
            player: finalDefensePlayer,
            players: game.players
        )

        game.timerManager.startTimer(
            seconds: GameTime.executionResult,
            onTimeout: {
                GameLogger.timer("처형 결과 발표 시간 종료")
                game.proceedAfterExecution()
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        // 투표는 이미 끝났고, 현재는 결과를 보여주는 상태이므로 별도 액션을 처리하지 않음
    }

    func exit(game: MafiaGame) {
        GameLogger.event("🫠 처형 결과 발표 상태 종료")
        game.timerManager.stopTimer()

        // 다음 라운드 찬반 투표에 이전 표가 누적되지 않도록 리셋
        game.voteManager.resetExecutionVotes()
    }
}
