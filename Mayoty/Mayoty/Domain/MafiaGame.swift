//
//  MafiaGame.swift
//  Mayoty
//
//  Created by sun on 6/2/26.
//

final class MafiaGame {
    private(set) var players: [Player]

    private(set) var currentState: any GameState

    init(
        players: [Player],
        initialState: any GameState
    ) {
        self.players = players
        self.currentState = initialState
        self.currentState.enter(game: self)
    }

    func handleAction(_ action: GameAction) {
        currentState.handleAction(
            game: self,
            action: action
        )
    }

    func changeState(to state: any GameState) {
        currentState.exit(game: self)
        currentState = state
        currentState.enter(game: self)
    }

    func endGame() {
        handleAction(.gameEnded)
    }
}
