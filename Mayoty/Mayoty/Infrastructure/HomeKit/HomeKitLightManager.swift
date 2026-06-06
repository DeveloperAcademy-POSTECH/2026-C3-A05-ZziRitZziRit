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
    
    var statusText = "Homekit 로딩 중..."
    var lights: [HMAccessory] = []
    
    override init() {
        super.init()
        
        let manager = HMHomeManager()
        manager.delegate = self
        self.homeManager = manager
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        loadLights(from: manager)
    }
    
    private func loadLights(from manager: HMHomeManager) {
        guard let home = manager.homes.first else {
            statusText = "등록된 Home이 없습니다."
            return
        }
        lights = home.accessories.filter {
            HomeKitLightService.isLight($0)
        }
        
        statusText = lights.isEmpty
            ? "조명을 찾지 못했습니다"
            : " \(lights.count)개 조명 발견"
    }
}
