//
//  DoctorState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct DoctorState: GameState {
    func enter(game: MafiaGame) {
        // 의사 선택 요청
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .doctorSelected(let target) = action else { return }

        game.selectHealTarget(target)
        game.changeState(to: DiscussionState())
    }

    func exit(game: MafiaGame) {

    }
}
