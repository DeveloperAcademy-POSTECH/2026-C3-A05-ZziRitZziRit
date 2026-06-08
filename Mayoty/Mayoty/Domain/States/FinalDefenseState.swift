//
//  FinalDefenseState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct FinalDefenseState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🎤 최후 변론 시작")
        
        guard let finalDefensePlayer = game.finalDefensePlayer else {
            return
        }
        
        game.lightManager.setFinalDefenseScene(
            player: finalDefensePlayer,
            players: game.players
        )
        
        GameLogger.event(
            "🎤 최후 변론 대상자: \(finalDefensePlayer.color?.rawValue ?? "Unknown")"
        )
        
        game.timerManager.startTimer(
            seconds: GameTime.finalDefense,
            onTimeout: {
                GameLogger.timer("최후 변론 시간 종료")
                game.changeState(to: ExecutionVoteState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .finalDefenseEnded = action else { return }
        
        GameLogger.event("🎤 최후 변론 종료")
        
        game.changeState(to: ExecutionVoteState())
    }
    
    func exit(game: MafiaGame) {
        GameLogger.event("🎤 최후 변론 상태 종료")
        game.timerManager.stopTimer()
    }
}
