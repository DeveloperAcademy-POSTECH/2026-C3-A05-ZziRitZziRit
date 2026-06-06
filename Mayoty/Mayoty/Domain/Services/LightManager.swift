//
//  LightManager.swift
//  Mayoty
//
//  Created by sun on 6/5/26.
//

final class LightManager {
    private let homeKitLightManager: HomeKitLightManager
    
    init(homeKitLightManager: HomeKitLightManager) {
        self.homeKitLightManager = homeKitLightManager
    }
    
    /// 낮 조명
    func setPlayerColorScene(players: [Player]) {
        for (player, light) in zip(players, homeKitLightManager.lights) {
            guard let color = player.color else { continue }
            
            HomeKitLightService.setPower(light, isOn: true)
            HomeKitLightService.setColor(
                light,
                hue: color.hue,
                saturation: color.saturation,
                brightness: 100
            )
        }
    }
    
    /// 밤 조명
    func setNightScene() {
        homeKitLightManager.lights.forEach {
            HomeKitLightService.setColor(
                $0,
                hue: 240,
                saturation: 100,
                brightness: 50
            )
        }
    }
    
    /// 최후 변론 조명
    func setFinalDefenseScene(player: Player, players: [Player]) {
        for (currentPlayer, light) in zip(players, homeKitLightManager.lights) {
            guard currentPlayer.id == player.id else {
                HomeKitLightService.setPower(light, isOn: false)
                continue
            }

            let color = player.color

            HomeKitLightService.setPower(light, isOn: true)
            HomeKitLightService.setColor(
                light,
                hue: color?.hue ?? 45,
                saturation: color?.saturation ?? 100,
                brightness: 100
            )
        }
    }
    
    /// 결과 조명
    func setResultScene(winner: Team) {
        let hue: Double
        
        switch winner {
        case .mafia:
            hue = 0
        case .citizens:
            hue = 120
        }
        
        homeKitLightManager.lights.forEach {
            HomeKitLightService.setColor(
                $0,
                hue: hue,
                saturation: 100,
                brightness: 100
            )
        }
    }
    
    /// 종료 조명
    func turnOffAllLights() {
        homeKitLightManager.lights.forEach {
            HomeKitLightService.setPower($0, isOn: false)
        }
    }
}
