//
//  ResultState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct ResultState: GameState {
    func enter(game: MafiaGame) {
        guard let winner = game.winner else {
            GameLogger.result("🔴🟢 승자 정보 없음")
            return
        }

        GameLogger.result(
            winner == .mafia
            ? "🔴 마피아 승리"
            : "🟢 시민 승리"
        )

        game.soundManager.playResultSound(
            winner: winner
        )

        game.lightManager.setResultScene(
            winner: winner
        )
    }

    func handleAction(game: MafiaGame, action: GameAction) {
        switch action {
        case .gameEnded:
            GameLogger.event("🔴🟢 게임 종료")
            game.endGame()

        default:
            break
        }
    }

    func exit(game: MafiaGame) {
        GameLogger.event("🔴🟢 결과 상태 종료")
        game.soundManager.stopAll()
    }
}
