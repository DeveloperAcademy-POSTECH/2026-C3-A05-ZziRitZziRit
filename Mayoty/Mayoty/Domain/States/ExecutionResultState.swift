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
                game.changeState(to: ResultState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .executionVoteCompleted = action else { return }
        
        game.changeState(to: ResultState())
    }
    
    func exit(game: MafiaGame) {
        game.timerManager.stopTimer()
    }
}
