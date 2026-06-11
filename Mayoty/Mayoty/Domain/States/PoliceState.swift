//
//  PoliceState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct PoliceState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("👮‍♂️ 경찰 수사 시작")

        game.watchCommandManager.sendPoliceTurn(
            to: game.players
        )

        game.soundManager.playPoliceStartSound()

        game.timerManager.startTimer(
            seconds: GameTime.police,
            onTimeout: {
                GameLogger.timer("경찰 수사 시간 종료")
                transitionToDoctor(game: game)
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .policeSelected(let target) = action else { return }

        game.selectInvestigateTarget(target)

        let isMafia = target.role?.team == .mafia

        GameLogger.event(
            "👮‍♂️ 경찰 수사 완료: \(isMafia ? "마피아" : "시민")"
        )

        game.watchCommandManager.sendPoliceResult(
            isMafia: isMafia,
            to: game.players
        )

        transitionToDoctor(game: game)
    }

    func exit(game: MafiaGame) {
        GameLogger.event("👮‍♂️ 경찰 수사 종료")
        game.timerManager.stopTimer()
    }

    private func transitionToDoctor(game: MafiaGame) {
        game.timerManager.stopTimer()

        game.runAfterNarration({
            await game.soundManager.playPoliceEndSoundAndWait()
        }) {
            game.changeState(to: DoctorState())
        }
    }
}
