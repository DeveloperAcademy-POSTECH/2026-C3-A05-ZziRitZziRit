//
//  VoteState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct VoteState: GameState {
    func enter(game: MafiaGame) {
        game.timerManager.startTimer(
            seconds: GameTime.vote,
            onTimeout: {
                finishVote(game: game)
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .voteSubmitted(let voter, let target):
            game.voteManager.submitVote(
                voter: voter,
                target: target
            )

        case .voteCompleted:
            finishVote(game: game)

        default:
            break
        }
    }

    func exit(game: MafiaGame) {
        game.timerManager.stopTimer()
    }

    private func finishVote(game: MafiaGame) {
        guard let finalDefensePlayer = game.voteManager.getSingleTopVotedPlayer(
            from: game.players
        ) else {
            game.voteManager.resetTargetVotes()
            game.changeState(to: NightState())
            return
        }

        game.selectFinalDefensePlayer(finalDefensePlayer)
        game.voteManager.resetTargetVotes()
        game.changeState(to: FinalDefenseState())
    }
}

