//
//  VoteState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct VoteState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🗳️ 투표 시작")

        game.watchCommandManager.sendVote(to: game.players)

        game.soundManager.playVoteStartSound()
        game.lightManager.setNightScene()

        game.timerManager.startTimer(
            seconds: GameTime.vote,
            onTimeout: {
                GameLogger.timer("투표 시간 종료")
                finishVote(game: game)
            }
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .voteSubmitted(let voter, let target):
            GameLogger.event(
                "🗳️ \(voter.color?.rawValue ?? "Unknown") → \(target.color?.rawValue ?? "Unknown") 투표"
            )

            game.voteManager.submitVote(
                voter: voter,
                target: target
            )

            if game.voteManager.hasAllVotes(from: game.players) {
                GameLogger.event("🗳️ 전원 투표 완료 — 조기 종료")
                finishVote(game: game)
            }

        case .voteCompleted:
            GameLogger.event("🗳️ 모든 플레이어 투표 완료")
            finishVote(game: game)

        default:
            break
        }
    }

    func exit(game: MafiaGame) {
        GameLogger.event("🗳️ 투표 상태 종료")
        game.timerManager.stopTimer()
        game.soundManager.stopAll()
    }

    private func finishVote(game: MafiaGame) {
        game.timerManager.stopTimer()

        let result = game.voteManager.getVoteResult(from: game.players)

        switch result {
        case .noVotes:
            GameLogger.event("🗳️ 무투표 - 밤으로 이동")

            game.voteManager.resetTargetVotes()

            game.runAfterNarration({
                await game.soundManager.playVoteCompletedSoundAndWait(
                    fileName: "voteCompleted-noVotes"
                )
            }) {
                game.changeState(to: NightState())
            }

        case .tie:
            GameLogger.event("🗳️ 동점 - 밤으로 이동")

            game.voteManager.resetTargetVotes()

            game.runAfterNarration({
                await game.soundManager.playVoteCompletedSoundAndWait(
                    fileName: "voteCompleted-tie"
                )
            }) {
                game.changeState(to: NightState())
            }

        case .singleTop(let finalDefensePlayer):
            GameLogger.event(
                "🗳️ 최다 득표자 선정: \(finalDefensePlayer.color?.rawValue ?? "Unknown")"
            )

            game.selectFinalDefensePlayer(finalDefensePlayer)
            game.voteManager.resetTargetVotes()

            let colorName = finalDefensePlayer.color?.rawValue ?? "unknown"

            game.runAfterNarration({
                await game.soundManager.playVoteCompletedSoundAndWait(
                    fileName: "voteCompleted-\(colorName)"
                )
            }) {
                game.changeState(to: FinalDefenseState())
            }
        }
    }
}
