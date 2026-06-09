//
//  WaitingState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct WaitingState: GameState {
    func enter(game: MafiaGame) {
        // 플레이어 대기 상태
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .startGame = action else { return }

        Task {
            await GameAudioManager.shared.playNarrationAndWait(named: "startGame")
            game.changeState(to: RoleAssigningState())
        }
    }

    func exit(game: MafiaGame) {
        // 대기 상태 종료 처리
    }
}
