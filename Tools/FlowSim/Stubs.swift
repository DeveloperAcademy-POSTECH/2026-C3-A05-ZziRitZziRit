//
//  Stubs.swift — FlowSim 전용 스텁
//
//  실제 앱의 다음 파일을 대체한다 (컴파일 목록에서 원본 제외):
//  - GameTime.swift            → 페이즈 시간을 1초로 단축
//  - GameAudioManager.swift    → 즉시 반환 + 재생 기록
//  - LightManager.swift        → no-op + 호출 기록 (HomeKit 제거)
//  - HomeKitLightManager.swift → 빈 껍데기
//  - iPhoneBLEPeripheralManager.swift → 인메모리 전송 (encode→decode 왕복 검증)
//
//  나머지(MafiaGame/상태머신/BLEViewModel/WatchCommandManager/WatchCommandStore 등)는
//  전부 실제 프로덕션 소스를 그대로 컴파일한다.
//

import Foundation

// MARK: - GameTime (1초 단축판)

enum GameTime {
    // 타이머로만 진행되는 페이즈: 1초로 단축
    static var roleAssigning = 1
    static var introduction = 1
    static var discussion = 1
    static var finalDefense = 1
    static var executionResult = 1

    // 워치 답변으로 진행되는 페이즈: 시나리오의 답변이 타임아웃보다
    // 먼저 처리되도록 충분히 길게 (조기 종료 검증이 진짜가 되도록)
    // 시나리오에 따라 가변 (타임아웃 시나리오는 1초로 전환)
    static var mafia = 30
    static var police = 30
    static var doctor = 30
    static var vote = 30
    static var executionVote = 30

    static func useActionDrivenTimes() {
        roleAssigning = 1; introduction = 1; discussion = 1
        finalDefense = 1; executionResult = 1
        mafia = 30; police = 30; doctor = 30; vote = 30; executionVote = 30
    }

    static func useAllShortTimes() {
        roleAssigning = 1; introduction = 1; discussion = 1
        finalDefense = 1; executionResult = 1
        mafia = 1; police = 1; doctor = 1; vote = 1; executionVote = 1
    }
}

// MARK: - GameAudioManager (즉시 반환)

final class GameAudioManager {
    static let shared = GameAudioManager()

    /// 재생 요청된 나레이션 파일명 기록 — 시나리오에서 검증
    private(set) var playedNarrations: [String] = []
    private(set) var playedBgms: [String] = []

    private init() {}

    func reset() {
        playedNarrations = []
        playedBgms = []
    }

    func count(ofNarration name: String) -> Int {
        playedNarrations.filter { $0 == name }.count
    }

    func count(ofBgm name: String) -> Int {
        playedBgms.filter { $0 == name }.count
    }

    func setupAudioSession() {}

    func playBGM(named fileName: String) {
        playedBgms.append(fileName)
    }

    func playNarrationsInOrder(named fileNames: [String]) {
        playedNarrations.append(contentsOf: fileNames)
    }

    func playNarration(named fileName: String) {
        playedNarrations.append(fileName)
    }

    func playNarrationAfterDelay(named fileName: String, delay seconds: TimeInterval) {
        playedNarrations.append(fileName)
    }

    func playSoundEffectsInOrder(named fileNames: [String]) {}
    func playSoundEffect(named fileName: String) {}
    func stopAll() {}

    func playNarrationAndWait(named fileName: String) async {
        playedNarrations.append(fileName)
        // 실제 나레이션 대기를 흉내 — 전이 레이스 가드가 의미 있게 동작하도록 약간의 지연
        try? await Task.sleep(for: .milliseconds(50))
    }
}

// MARK: - HomeKit 스텁

final class HomeKitLightManager {
    init() {}
}

final class LightManager {
    private(set) var sceneLog: [String] = []

    init(homeKitLightManager: HomeKitLightManager) {}

    func assignLights(to players: [Player]) { sceneLog.append("assign") }
    func setPlayerColorScene(players: [Player]) { sceneLog.append("day") }
    func setNightScene() { sceneLog.append("night") }
    func setFinalDefenseScene(player: Player, players: [Player]) { sceneLog.append("finalDefense") }
    func setResultScene(winner: Team) { sceneLog.append("result-\(winner)") }
    func turnOffAllLights() { sceneLog.append("off") }
}

// MARK: - BLE 전송 스텁 (인메모리)

enum BLEPeripheralEvent {
    case bluetoothStateChanged(String, log: String?)
    case advertisingChanged(Bool, log: String)
    case watchConnected(id: UUID)
    case watchDisconnected(id: UUID)
    case answerReceived(id: UUID, answer: BLEAnswer)
    case log(String)
}

final class iPhoneBLEPeripheralManager {

    let events: AsyncStream<BLEPeripheralEvent>
    private let continuation: AsyncStream<BLEPeripheralEvent>.Continuation

    /// 명령 송신 훅 — 시나리오가 가상 워치들에 라우팅
    var onCommand: ((BLECommand, UUID?) -> Void)?

    private(set) var isAdvertisingNow = false

    init() {
        let stream = AsyncStream.makeStream(of: BLEPeripheralEvent.self)
        self.events = stream.stream
        self.continuation = stream.continuation
    }

    func activate() {}

    func startAdvertising() { isAdvertisingNow = true }
    func stopAdvertising() { isAdvertisingNow = false }

    func sendCommand(_ command: BLECommand, to centralID: UUID? = nil) {
        // 실제 전송처럼 Data 인코딩 → 디코딩 왕복으로 프로토콜 대칭 검증
        guard let decoded = BLECommand(data: command.data) else {
            print("❌ [FATAL] BLECommand encode→decode 왕복 실패: \(command.kind)")
            exit(1)
        }

        onCommand?(decoded, centralID)
    }

    /// 시나리오에서 워치 연결/해제/응답 이벤트 주입
    func inject(_ event: BLEPeripheralEvent) {
        continuation.yield(event)
    }
}
