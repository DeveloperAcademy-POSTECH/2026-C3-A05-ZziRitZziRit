//
//  NightState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct NightState: GameState {
    func enter(game: MafiaGame) {
        game.changeState(to: MafiaState())
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
    }
    
    func exit(game: MafiaGame) {
    }
}
