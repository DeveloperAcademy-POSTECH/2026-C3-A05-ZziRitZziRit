//
//  HomeKitLightManager.swift
//  Mayoty
//
//  Created by sun on 6/5/26.
//

import HomeKit
import Observation

@Observable
final class HomeKitLightManager: NSObject, HMHomeManagerDelegate {
    private var homeManager: HMHomeManager?
    var lights: [HMAccessory] = []

    override init() {
        super.init()

        let manager = HMHomeManager()
        manager.delegate = self
        self.homeManager = manager

        GameLogger.light("HomeKitLightManager 초기화")
    }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        GameLogger.light("HomeKit Home 목록 업데이트됨")
        loadLights(from: manager)
    }

    private func loadLights(from manager: HMHomeManager) {
        GameLogger.light("Home 개수: \(manager.homes.count)")

        guard let home = manager.homes.first else {
            GameLogger.light("등록된 Home 없음")
            return
        }

        GameLogger.light("선택된 Home: \(home.name)")
        GameLogger.light("전체 액세서리 수: \(home.accessories.count)")

        for accessory in home.accessories {
            GameLogger.light("액세서리: \(accessory.name)")

            for service in accessory.services {
                GameLogger.light(" - 서비스: \(service.name), type: \(service.serviceType)")
            }
        }

        lights = home.accessories.filter {
            HomeKitLightService.isLight($0)
        }

        GameLogger.light("필터링된 조명 수: \(lights.count)")
    }

    func turnOnLight(_ accessory: HMAccessory) {
        setLight(accessory, isOn: true)
    }

    func turnOffLight(_ accessory: HMAccessory) {
        setLight(accessory, isOn: false)
    }

    func setLight(_ accessory: HMAccessory, isOn: Bool) {

        GameLogger.light("\(accessory.name) \(isOn ? "ON" : "OFF") 요청")

        HomeKitLightService.setPower(accessory, isOn: isOn) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }

                if let error {
                    GameLogger.light("\(accessory.name) 제어 실패: \(error.localizedDescription)")
                } else {
                    GameLogger.light("\(accessory.name) \(isOn ? "ON" : "OFF") 성공")
                }
            }
        }
    }

    func setColor(_ accessory: HMAccessory, color: HomeKitLightColor) {

        GameLogger.light("\(accessory.name) 색상 변경 요청: \(color)")

        HomeKitLightService.setColor(color, accessory: accessory) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }

                if let error {
                    GameLogger.light("\(accessory.name) 색상 변경 실패: \(error.localizedDescription)")
                } else {
                    GameLogger.light("\(accessory.name) 색상 변경 성공: \(color)")
                }
            }
        }
    }
}

