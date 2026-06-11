//
//  NightState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct NightState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("🌙 밤 시작")
        game.lightManager.setNightScene(players: game.players)
        // TODO: BLE payload/configuration 처리 완료 이벤트 이후 MafiaState로
        
        game.changeState(to: MafiaState())
        
        GameAudioManager.shared.playBGM(named: "nightBgm")
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
    }
    
    func exit(game: MafiaGame) {
        GameLogger.event("🌙 밤 종료")
    }
}
