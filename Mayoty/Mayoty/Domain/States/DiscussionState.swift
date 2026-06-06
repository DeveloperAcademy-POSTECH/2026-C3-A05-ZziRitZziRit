//
//  DiscussionState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct DiscussionState: GameState {
    func enter(game: MafiaGame) {
        game.lightManager.setPlayerColorScene(
            players: game.players
        )
        game.timerManager.startTimer(
            seconds: GameTime.discussion,
            onTimeout: {
                game.changeState(to: VoteState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .discussionEnded = action else { return }
        
        game.changeState(to: VoteState())
    }
    
    func exit(game: MafiaGame) {
        // 토론 종료 처리
    }
}
