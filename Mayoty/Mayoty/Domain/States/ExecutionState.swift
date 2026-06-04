//
//  ExecutionState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ExecutionState: GameState {
    func enter(game: MafiaGame) {
        // 처형 시작
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .executionCompleted:
            game.changeState(to: ResultState())
        
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        // 처형 종료 처리
    }
}
