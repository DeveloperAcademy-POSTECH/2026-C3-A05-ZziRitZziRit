//
//  ExecutionVoteState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ExecutionVoteState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("👍 처형 찬반 투표 시작")
        
        game.lightManager.setNightScene()
        game.timerManager.startTimer(
            seconds: GameTime.executionVote,
            onTimeout: {
                GameLogger.timer("처형 찬반 투표 시간 종료")
                game.changeState(to: ExecutionResultState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .executionVoteSubmitted(let voter, let isAgree):
            guard let finalDefensePlayer = game.finalDefensePlayer else { return }
            
            GameLogger.event(
                "👍 \(voter.color?.rawValue ?? "Unknown") 처형 투표: \(isAgree ? "찬성" : "반대")"
            )
            
            game.voteManager.submitExecutionVote(
                voter: voter,
                finalDefensePlayer: finalDefensePlayer,
                isAgree: isAgree
            )
            
        case .executionVoteCompleted:
            GameLogger.event("👍 처형 찬반 투표 완료")
            game.changeState(to: ExecutionResultState())
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        GameLogger.event("👍 처형 찬반 투표 상태 종료")
        game.timerManager.stopTimer()
    }
}

