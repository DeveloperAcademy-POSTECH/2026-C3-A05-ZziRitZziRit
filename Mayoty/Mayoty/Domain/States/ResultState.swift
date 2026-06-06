//
//  ResultState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ResultState: GameState {
    func enter(game: MafiaGame) {
        guard let winner = game.winner else { return }
        
        game.lightManager.setResultScene(
            winner: winner
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .gameEnded:
            game.endGame()
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        // 결과 상태 종료 처리
    }
}
