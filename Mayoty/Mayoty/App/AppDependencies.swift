//
//  AppDependencies.swift
//  Mayoty
//
//  Created by Claude on 6/11/26.
//

/// BLE/HomeKit 스택은 앱 생애 동안 1회만 생성되어야 함
/// (CBPeripheralManager·HMHomeManager를 뷰 재평가마다 만들면
/// 중복 광고/빈 조명 목록 문제가 발생)
final class AppDependencies {
    let peripheralManager: iPhoneBLEPeripheralManager
    let homeKitLightManager: HomeKitLightManager
    let watchCommandManager: WatchCommandManager
    let bleViewModel: BLEViewModel

    init() {
        let peripheralManager = iPhoneBLEPeripheralManager()
        let homeKitLightManager = HomeKitLightManager()
        let watchCommandManager = WatchCommandManager(
            peripheralManager: peripheralManager
        )

        let initialGame = MafiaGame(
            players: [],
            initialState: WaitingState(),
            homeKitLightManager: homeKitLightManager,
            watchCommandManager: watchCommandManager
        )

        self.peripheralManager = peripheralManager
        self.homeKitLightManager = homeKitLightManager
        self.watchCommandManager = watchCommandManager
        self.bleViewModel = BLEViewModel(
            game: initialGame,
            peripheralManager: peripheralManager,
            watchCommandManager: watchCommandManager
        )
    }

    /// 첫 화면 표시 시점에 BLE/HomeKit 시스템 연결을 시작 (호출 전까지는 객체만 준비)
    /// @main 부트스트랩(App init) 중에 CoreBluetooth/HomeKit 데몬 연결을 만들지 않기 위함
    func activate() {
        peripheralManager.activate()
        homeKitLightManager.activate()
    }
}
