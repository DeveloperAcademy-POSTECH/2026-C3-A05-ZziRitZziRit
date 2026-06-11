//
//  NightState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct NightState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🌙 밤 시작")
        game.lightManager.setNightScene()
        game.soundManager.playNightBgm()

        game.changeState(to: MafiaState())
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
    }
    
    func exit(game: MafiaGame) {
        GameLogger.event("🌙 밤 종료")
    }
}
