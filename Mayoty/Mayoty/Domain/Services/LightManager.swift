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
                color.homeKitColor,
                accessory: light
            )
        }
    }
    
    /// 밤 조명
    func setNightScene() {
        homeKitLightManager.lights.forEach {
            HomeKitLightService.setColor(
                .night,
                accessory: $0
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

            HomeKitLightService.setPower(light, isOn: true)
            HomeKitLightService.setColor(
                player.color?.homeKitColor ?? .finalDefenseFallback,
                accessory: light
            )
        }
    }
    
    /// 결과 조명
    func setResultScene(winner: Team) {
        let color: HomeKitLightColor

        switch winner {
        case .mafia:
            color = .mafiaWin
        case .citizens:
            color = .citizenWin
        }

        homeKitLightManager.lights.forEach {
            HomeKitLightService.setColor(
                color,
                accessory: $0
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
