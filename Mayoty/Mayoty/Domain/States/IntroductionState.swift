//
//  IntroductionState.swift
//  Mayoty
//
//  Created by sun on 6/4/26.
//

struct IntroductionState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("👋 자기소개 시작")
        
        game.lightManager.setPlayerColorScene(
            players: game.players
        )
        game.timerManager.startTimer(
            seconds: GameTime.introduction,
            onTimeout: {
                GameLogger.timer("자기소개 시간 종료")
                game.changeState(to: NightState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .introductionEnded = action else { return }
        
        GameLogger.event("👋 자기소개 종료")
        
        game.changeState(to: VoteState())
    }
    
    func exit(game: MafiaGame) {
        GameLogger.event("👋 자기소개 상태 종료")
        game.timerManager.stopTimer()
    }
}
