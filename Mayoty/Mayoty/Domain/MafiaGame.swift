//
//  MafiaGame.swift
//  Mayoty
//
//  Created by sun on 6/2/26.
//

final class MafiaGame {
    private(set) var players: [Player]

    private(set) var currentState: any GameState

    private(set) var mafiaTarget: Player?
    private(set) var policeTarget: Player?
    private(set) var doctorTarget: Player?

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

    func selectMafiaTarget(_ player: Player) {
        mafiaTarget = player
    }

    func investigateTarget(_ player: Player) {
        policeTarget = player
    }

    func selectDoctorTarget(_ player: Player) {
        doctorTarget = player
    }

    func resetNightTargets() {
        mafiaTarget = nil
        policeTarget = nil
        doctorTarget = nil
    }

    func endGame() {
        handleAction(.gameEnded)
    }
}
