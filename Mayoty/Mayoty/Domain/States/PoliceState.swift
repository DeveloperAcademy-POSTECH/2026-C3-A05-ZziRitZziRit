//
//  PoliceState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct PoliceState: GameState {
    func enter(game: MafiaGame) {
        // 경찰 선택 요청
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .policeSelected(let target):
            game.investigateTarget(target)
            game.changeState(to: DoctorState())
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        
    }
}
