//
//  GameState.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

protocol GameState {
    func enter(game: MafiaGame)

    func handleAction(
        game: MafiaGame,
        action: GameAction
    )

    func exit(game: MafiaGame)

    func proceedAfterNight(game: MafiaGame)

    func proceedAfterExecution(game: MafiaGame)
}

extension GameState {
    func proceedAfterNight(game: MafiaGame) { }

    func proceedAfterExecution(game: MafiaGame) { }
}

