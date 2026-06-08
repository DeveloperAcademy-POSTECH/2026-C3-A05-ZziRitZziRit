//
//  MafiaState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct MafiaState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🦹‍♂️ 마피아 선택 시작")
        
        game.timerManager.startTimer(
            seconds: GameTime.mafia,
            onTimeout: {
                game.changeState(to: PoliceState())
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .mafiaSelected(let target) = action else { return }
        
        GameLogger.action(action)
        GameLogger.event("🦹‍♂️ 마피아 타겟 선택 완료: \(target.color?.rawValue ?? "색상 없음")")
        
        // TODO: BLE payload 처리 완료 이벤트(didProcessMafiaTarget) 이후 PoliceState로

        game.selectMafiaTarget(target)
        game.changeState(to: PoliceState())
    }

    func exit(game: MafiaGame) {
        GameLogger.event("🦹‍♂️ 마피아 선택 종료")
        game.timerManager.stopTimer()
    }
}
