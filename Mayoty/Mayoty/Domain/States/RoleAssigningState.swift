//
//  RoleAssigningState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct RoleAssigningState: GameState {
    func enter(game: MafiaGame) {
        game.roleManager.assignRoles(to: game.players)
        game.colorManager.assignColors(to: game.players)

        game.timerManager.startTimer(
            seconds: GameTime.roleAssigning,
            onTimeout: {
                game.handleAction(.rolesAssigned)
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .rolesAssigned = action else { return }

        game.changeState(to: IntroductionState())
    }

    func exit(game: MafiaGame) {
        // 역할 배정 종료 처리
    }
}
