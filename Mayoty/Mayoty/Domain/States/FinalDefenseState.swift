//
//  FinalDefenseState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct FinalDefenseState: GameState {
    func enter(game: MafiaGame) {
        guard let finalDefensePlayer = game.finalDefensePlayer else {
            return
        }
        
        game.lightManager.setFinalDefenseScene(
            player: finalDefensePlayer,
            players: game.players
        )
        
        game.timerManager.startTimer(
            seconds: GameTime.finalDefense,
            onTimeout: {
                game.changeState(to: ExecutionVoteState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .finalDefenseEnded = action else { return }
        
        game.changeState(to: ExecutionVoteState())
    }
    
    func exit(game: MafiaGame) {
        // 최후 변론 종료 처리
    }
}
