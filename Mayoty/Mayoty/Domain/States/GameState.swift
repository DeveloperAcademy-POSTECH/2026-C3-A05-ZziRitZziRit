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
    func proceedAfterNight(game: MafiaGame) {
        if let winner = game.resultManager.checkWinner(players: game.players) {
            game.setWinner(winner)
            game.changeState(to: ResultState())
        } else {
            game.changeState(to: DiscussionState())
        }
    }

    func proceedAfterExecution(game: MafiaGame) {
        if let winner = game.resultManager.checkWinner(players: game.players) {
            game.setWinner(winner)
            game.changeState(to: ResultState())
        } else {
            game.changeState(to: MafiaState())
        }
    }
}
