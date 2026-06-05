//
//  ExecutionResultState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ExecutionResultState: GameState {
    func enter(game: MafiaGame) {
        game.timerManager.startTimer(
            seconds: GameTime.executionResult,
            onTimeout: {
                game.proceedAfterExecution()
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        // 투표는 이미 끝났고, 현재는 결과를 보여주는 상태이므로 별도 액션을 처리하지 않음
    }

    func exit(game: MafiaGame) {
        game.timerManager.stopTimer()
    }
}
