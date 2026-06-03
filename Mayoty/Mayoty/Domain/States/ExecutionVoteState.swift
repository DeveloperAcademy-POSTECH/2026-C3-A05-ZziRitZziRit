//
//  ExecutionVoteState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ExecutionVoteState: GameState {
    func enter(game: MafiaGame) {
        // 처형 찬반 투표 시작
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .executionVoteCompleted = action else { return }

        game.changeState(to: ExecutionResultState())
    }

    func exit(game: MafiaGame) {
        // 처형 찬반 투표 종료
    }
}
