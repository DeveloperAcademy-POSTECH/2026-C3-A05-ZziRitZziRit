//
//  VoteState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct VoteState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🗳️ 투표 시작")
        
        game.lightManager.setNightScene()
        game.timerManager.startTimer(
            seconds: GameTime.vote,
            onTimeout: {
                GameLogger.timer("투표 시간 종료")
                finishVote(game: game)
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .voteSubmitted(let voter, let target):
            GameLogger.event(
                "🗳️ \(voter.color?.rawValue ?? "Unknown") → \(target.color?.rawValue ?? "Unknown") 투표"
            )
            game.voteManager.submitVote(
                voter: voter,
                target: target
            )
            
        case .voteCompleted:
            GameLogger.event("🗳️ 모든 플레이어 투표 완료")
            finishVote(game: game)
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        GameLogger.event("🗳️ 투표 상태 종료")
        game.timerManager.stopTimer()
    }
    
    private func finishVote(game: MafiaGame) {
        guard let finalDefensePlayer = game.voteManager.getSingleTopVotedPlayer(
            from: game.players
        ) else {
            GameLogger.event("🗳️ 최다 득표자 없음 - 밤으로 이동")
            game.voteManager.resetTargetVotes()
            game.changeState(to: NightState())
            return
        }
        
        GameLogger.event(
            "🗳️ 최다 득표자 선정: \(finalDefensePlayer.color?.rawValue ?? "Unknown")"
        )
        
        game.selectFinalDefensePlayer(finalDefensePlayer)
        game.voteManager.resetTargetVotes()
        game.changeState(to: FinalDefenseState())
    }
}

