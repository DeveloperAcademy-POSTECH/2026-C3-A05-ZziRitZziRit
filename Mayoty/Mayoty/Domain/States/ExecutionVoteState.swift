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
        switch action {
        case .executionVoteCompleted:
            game.changeState(to: ExecutionResultState())

        default:
            break
        }
    }

    func exit(game: MafiaGame) {
        // 처형 찬반 투표 종료
    }
}
