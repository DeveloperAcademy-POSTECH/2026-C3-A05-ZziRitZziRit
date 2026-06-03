//
//  RoleAssigningState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct RoleAssigningState: GameState {
    func enter(game: MafiaGame) {
        // 역할 배정 시작
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .rolesAssigned = action else { return }

        game.changeState(to: NightState())
    }

    func exit(game: MafiaGame) {
        // 역할 배정 종료 처리
    }
}
