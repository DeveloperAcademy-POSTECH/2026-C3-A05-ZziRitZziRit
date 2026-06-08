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
        GameLogger.light("플레이어 색상 조명 적용")

        for (player, light) in zip(players, homeKitLightManager.lights) {
            guard let color = player.color else { continue }

            GameLogger.light("\(color.rawValue) 색상 적용")

            HomeKitLightService.setPower(light, isOn: true)
            HomeKitLightService.setColor(
                color.homeKitColor,
                accessory: light
            )
        }
    }

    /// 밤 조명
    func setNightScene() {
        GameLogger.light("밤 조명 적용")

        homeKitLightManager.lights.forEach {
            HomeKitLightService.setColor(
                .night,
                accessory: $0
            )
        }
    }

    /// 최후 변론 조명
    func setFinalDefenseScene(
        player: Player,
        players: [Player]
    ) {
        GameLogger.light("최후 변론 조명 적용")

        for (currentPlayer, light) in zip(players, homeKitLightManager.lights) {
            guard currentPlayer.id == player.id else {
                HomeKitLightService.setPower(light, isOn: false)
                continue
            }

            GameLogger.light(
                "최후 변론 대상자 조명 ON"
            )

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
            GameLogger.light("마피아 승리 조명 적용 🔴")
            color = .mafiaWin

        case .citizens:
            GameLogger.light("시민 승리 조명 적용 🟢")
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
        GameLogger.light("모든 조명 OFF")

        homeKitLightManager.lights.forEach {
            HomeKitLightService.setPower($0, isOn: false)
        }
    }
}

