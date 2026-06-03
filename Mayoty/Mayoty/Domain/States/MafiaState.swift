//
//  MafiaState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct MafiaState: GameState {
    func enter(game: MafiaGame) {
        // 마피아 선택 요청
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .mafiaSelected(let target) = action else { return }
        
        // TODO: BLE payload 처리 완료 이벤트(didProcessMafiaTarget) 이후 PoliceState로

        game.selectMafiaTarget(target)
        game.changeState(to: PoliceState())
    }

    func exit(game: MafiaGame) {
    }
}
