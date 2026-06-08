//
//  DoctorState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct DoctorState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("👨‍⚕️ 의사 치료 시작")

        game.timerManager.startTimer(
            seconds: GameTime.doctor,
            onTimeout: {
                GameLogger.timer("의사 치료 시간 종료")
                game.proceedAfterNight()
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .doctorSelected(let target) = action else {
            return
        }

        game.selectHealTarget(target)

        GameLogger.event("👨‍⚕️ 의사 치료 대상 선택 완료")

        game.proceedAfterNight()
    }

    func exit(game: MafiaGame) {
        GameLogger.event("👨‍⚕️ 의사 치료 종료")
        game.timerManager.stopTimer()
    }
}

