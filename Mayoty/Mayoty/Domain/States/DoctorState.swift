//
//  DoctorState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct DoctorState: GameState {
    func enter(game: MafiaGame) {
        // 의사 선택 요청
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .doctorSelected(let target):
            game.selectMafiaTarget(target)
            game.changeState(to: DiscussionState())
            
        default:
            break
        }
    }
    
    func exit(game: MafiaGame) {
        
    }
}
