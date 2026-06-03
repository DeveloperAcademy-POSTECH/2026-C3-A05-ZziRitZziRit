//
//  ExecutionResultState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ExecutionResultState: GameState {
    func enter(game: MafiaGame) {
        // 처형 결과 발표 시작
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .executionCompleted:
            game.changeState(to: ResultState())

        default:
            break
        }
    }

    func exit(game: MafiaGame) {
        // 처형 결과 발표 종료
    }
}
