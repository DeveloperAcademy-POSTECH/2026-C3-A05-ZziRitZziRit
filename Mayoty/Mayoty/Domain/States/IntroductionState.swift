//
//  IntroductionState.swift
//  Mayoty
//
//  Created by sun on 6/4/26.
//

struct IntroductionState: GameState {
    func enter(game: MafiaGame) {
        game.lightManager.setPlayerColorScene(
            players: game.players
        )
        game.timerManager.startTimer(
            seconds: GameTime.introduction,
            onTimeout: {
                game.changeState(to: NightState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .introductionEnded = action else { return }
        
        game.changeState(to: VoteState())
    }
    
    func exit(game: MafiaGame) {
        // 자기소개 종료
    }
}
