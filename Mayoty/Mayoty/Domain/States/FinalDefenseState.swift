//
//  FinalDefenseState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct FinalDefenseState: GameState {
    func enter(game: MafiaGame) {
        // 최후 변론 시작
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .finalDefenseEnded = action else { return }

        game.changeState(to: ExecutionVoteState())
    }

    func exit(game: MafiaGame) {
        // 최후 변론 종료 처리
    }
}
