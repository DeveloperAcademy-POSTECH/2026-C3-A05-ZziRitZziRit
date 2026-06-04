//
//  VoteState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct VoteState: GameState {
    func enter(game: MafiaGame) {
        // 투표 시작
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .voteSubmitted:
            // 투표 저장
            
            break
        
        case .voteCompleted:
            game.changeState(to: FinalDefenseState())
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        // 투표 종료 처리
    }
}
