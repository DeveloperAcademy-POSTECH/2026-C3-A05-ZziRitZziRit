//
//  GameRuleManager.swift
//  Mayoty
//
//  Created by sun on 6/4/26.
//

final class GameRuleManager {
    
    // MARK: - 밤 결과 처리
    
    func applyNightResult(game: MafiaGame) {
        guard let mafiaTarget = game.mafiaTarget else {
            GameLogger.event("🦹‍♂️ 마피아 타겟 없음")
            return
        }
        
        if mafiaTarget.id != game.doctorTarget?.id {
            mafiaTarget.isAlive = false
            
            GameLogger.event(
                "❌ \(mafiaTarget.color?.rawValue ?? "알 수 없음") 사망"
            )
        } else {
            GameLogger.event(
                "⭕️ \(mafiaTarget.color?.rawValue ?? "알 수 없음") 치료 성공"
            )
        }
        
        game.resetNightTargets()
    }
    
    // MARK: - 최후 변론 결과 처리
    
    func applyExecutionResult(game: MafiaGame) {
        guard let finalDefensePlayer = game.finalDefensePlayer else {
            GameLogger.event("⚖️ 최후 변론자 없음")
            return
        }

        if game.voteManager.shouldBeExecuted {
            finalDefensePlayer.isAlive = false

            GameLogger.event(
                "❌ \(finalDefensePlayer.color?.rawValue ?? "알 수 없음") 처형"
            )
        } else {
            GameLogger.event(
                "⭕️ \(finalDefensePlayer.color?.rawValue ?? "알 수 없음") 생존"
            )
        }

        game.resetFinalDefensePlayer()
    }
}
