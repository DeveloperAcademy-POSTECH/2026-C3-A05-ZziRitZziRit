//
//  MafiaState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct MafiaState: GameState {
    func enter(game: MafiaGame) {
        // 마피아 선택 요청
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .mafiaSelected(let target):
            game.selectMafiaTarget(target)
            game.changeState(to: PoliceState())
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
    }
}
