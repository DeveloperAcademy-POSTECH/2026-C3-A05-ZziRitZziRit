//
//  LightManager.swift
//  Mayoty
//
//  Created by sun on 6/5/26.
//

import HomeKit

final class LightManager {
    private let homeKitLightManager: HomeKitLightManager

    init(homeKitLightManager: HomeKitLightManager) {
        self.homeKitLightManager = homeKitLightManager
    }

    private func applyColor(
        _ color: HomeKitLightColor,
        to light: HMAccessory
    ) {
        GameLogger.light("\(light.name) ON 요청")

        HomeKitLightService.setPower(light, isOn: true) { powerError in
            if let powerError {
                GameLogger.light("\(light.name) ON 실패: \(powerError.localizedDescription)")
                return
            }

            GameLogger.light("\(light.name) 색상 적용 요청: \(color)")

            HomeKitLightService.setColor(color, accessory: light) { colorError in
                if let colorError {
                    GameLogger.light("\(light.name) 색상 실패: \(colorError.localizedDescription)")
                } else {
                    GameLogger.light("\(light.name) 색상 성공: \(color)")
                }
            }
        }
    }

    /// 낮 조명
    func setPlayerColorScene(players: [Player]) {
        GameLogger.light("플레이어 색상 조명 적용")
        GameLogger.light("현재 등록된 조명 수: \(homeKitLightManager.lights.count)")

        for (player, light) in zip(players, homeKitLightManager.lights) {
            guard let color = player.color else { continue }

            GameLogger.light("\(color.rawValue) 색상 적용")
            applyColor(color.homeKitColor, to: light)
        }
    }

    /// 밤 조명
    func setNightScene() {
        GameLogger.light("밤 조명 적용 - 플레이어 색상 유지, 밝기 30%")

        homeKitLightManager.lights.forEach { light in
            HomeKitLightService.setPower(light, isOn: true) { powerError in
                if let powerError {
                    GameLogger.light("\(light.name) ON 실패: \(powerError.localizedDescription)")
                    return
                }

                HomeKitLightService.setBrightness(30, accessory: light) { brightnessError in
                    if let brightnessError {
                        GameLogger.light("\(light.name) 밝기 30% 실패: \(brightnessError.localizedDescription)")
                    } else {
                        GameLogger.light("\(light.name) 밝기 30% 적용 성공")
                    }
                }
            }
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

            GameLogger.light("최후 변론 대상자 조명 ON")

            applyColor(
                player.color?.homeKitColor ?? .finalDefenseFallback,
                to: light
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
            applyColor(color, to: $0)
        }
    }

    /// 종료 조명
    func turnOffAllLights() {
        GameLogger.light("모든 조명 OFF")

        homeKitLightManager.lights.forEach { light in
            HomeKitLightService.setPower(light, isOn: false) { error in
                if let error {
                    GameLogger.light("\(light.name) OFF 실패: \(error.localizedDescription)")
                } else {
                    GameLogger.light("\(light.name) OFF 성공")
                }
            }
        }
    }
}

