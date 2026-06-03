//
//  DiscussionState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct DiscussionState: GameState {
    func enter(game: MafiaGame) {
        // 토론 시작
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .discussionEnded:
            game.changeState(to: VoteState())
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        // 토론 종료 처리
    }
}
