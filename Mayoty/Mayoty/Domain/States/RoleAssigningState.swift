//
//  RoleAssigningState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct RoleAssigningState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("✅ 역할 배정 시작")

        game.watchCommandManager.sendRoleAssigning()

        game.soundManager.playRoleAssigningSounds()

        game.roleManager.assignRoles(to: game.players)
        GameLogger.event("✅ 역할 배정 성공")

        game.colorManager.assignColors(to: game.players)
        GameLogger.event("✅ 색상 배정 성공")
        
        game.watchCommandManager.sendPlayerColors(
            to: game.players
        )

        game.watchCommandManager.sendRoleResults(to: game.players)

        game.lightManager.setNightScene()

        game.timerManager.startTimer(
            seconds: GameTime.roleAssigning,
            onTimeout: {
                GameLogger.timer("역할 확인 시간 종료")
                game.handleAction(.rolesAssigned)
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .rolesAssigned = action else { return }
        
        GameLogger.event("✅ 역할 배정 상태 완료")
        game.changeState(to: IntroductionState())
    }
    
    func exit(game: MafiaGame) {
        game.timerManager.stopTimer()
        game.soundManager.stopAll()
    }
}
