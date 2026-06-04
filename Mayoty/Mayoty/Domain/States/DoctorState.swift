//
//  DoctorState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct DoctorState: GameState {
    func enter(game: MafiaGame) {
        game.timerManager.startTimer(
            seconds: GameTime.doctor,
            onTimeout: {
                game.changeState(to: DiscussionState())
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .doctorSelected(let target) = action else { return }

        game.selectHealTarget(target)
        game.changeState(to: DiscussionState())
    }

    func exit(game: MafiaGame) {

    }
}
