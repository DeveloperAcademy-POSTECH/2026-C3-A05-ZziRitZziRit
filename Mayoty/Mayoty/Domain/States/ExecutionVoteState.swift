//
//  ExecutionVoteState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ExecutionVoteState: GameState {
    func enter(game: MafiaGame) {
        game.timerManager.startTimer(
            seconds: GameTime.executionVote,
            onTimeout: {
                game.changeState(to: ExecutionResultState())
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .executionVoteSubmitted(let voter, let isAgree):
            guard let finalDefensePlayer = game.finalDefensePlayer else { return }

            game.voteManager.submitExecutionVote(
                voter: voter,
                finalDefensePlayer: finalDefensePlayer,
                isAgree: isAgree
            )

        case .executionVoteCompleted:
            game.changeState(to: ExecutionResultState())

        default:
            break
        }
    }

    func exit(game: MafiaGame) {
        game.timerManager.stopTimer()
    }
}

