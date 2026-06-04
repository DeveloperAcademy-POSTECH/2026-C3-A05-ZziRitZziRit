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
                game.proceedAfterNight()
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .doctorSelected(let target) = action else { return }

        game.selectHealTarget(target)
        game.proceedAfterNight()
    }

    func exit(game: MafiaGame) {
        game.timerManager.stopTimer()
    }
}
