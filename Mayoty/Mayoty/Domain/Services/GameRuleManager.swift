//
//  GameRuleManager.swift
//  Mayoty
//
//  Created by sun on 6/4/26.
//

final class GameRuleManager {

    // MARK: - 밤 결과 처리

    func applyNightResult(game: MafiaGame) {
        guard let mafiaTarget = game.mafiaTarget else { return }

        if mafiaTarget.id != game.doctorTarget?.id {
            mafiaTarget.isAlive = false
        }

        game.resetNightTargets()
    }

    // MARK: - 최후 변론 결과 처리

    func applyExecutionResult(game: MafiaGame) {
        guard game.voteManager.shouldBeExecuted,
              let finalDefensePlayer = game.finalDefensePlayer
        else {
            game.resetFinalDefensePlayer()
            return
        }

        finalDefensePlayer.isAlive = false
        game.resetFinalDefensePlayer()
    }
}
