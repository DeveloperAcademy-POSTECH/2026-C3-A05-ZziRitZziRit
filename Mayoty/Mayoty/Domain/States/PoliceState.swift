//
//  PoliceState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct PoliceState: GameState {
    func enter(game: MafiaGame) {
        game.timerManager.startTimer(
            seconds: GameTime.police,
            onTimeout: {
                game.changeState(to: DoctorState())
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .policeSelected(let target) = action else { return }

        game.selectInvestigateTarget(target)
        game.changeState(to: DoctorState())
    }

    func exit(game: MafiaGame) {

    }
}
