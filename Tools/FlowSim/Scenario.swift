//
//  Scenario.swift — Mayoty 멀티워치 풀게임 시뮬레이션
//
//  가상 워치 5대가 실제 프로덕션 코드(MafiaGame/상태머신/BLEViewModel/
//  WatchCommandManager/WatchCommandStore/BLECommandQueue)를 통해 플레이한다.
//  전송 계층만 인메모리 스텁 — BLECommand는 Data 인코딩/디코딩을 왕복한다.
//
//  시나리오 1: 해피 패스 — 참가→역할→밤→사망자 플로우→투표→처형→시민 승리→재게임
//  시나리오 2: 3라운드 — 치료 성공, 처형 부결(생존), 처형 후 밤 경유,
//             라운드 간 투표 리셋, 죽은 직업자, 마피아 승리 (2라운드 회귀 검증)
//  시나리오 3: 타임아웃 풀사이클(무지목/무투표) + 이중 전이 레이스
//  시나리오 4: BLE 재전송 큐(BLECommandQueue) — 큐 가득/순서 보장/부분 flush
//

import Foundation

// MARK: - 가상 워치

@MainActor
final class WatchAgent {
    let id = UUID()
    let name: String
    let store = WatchCommandStore()

    private(set) var received: [BLECommandKind] = []

    init(name: String) {
        self.name = name
    }

    func receive(_ command: BLECommand) {
        received.append(command.kind)
        store.handle(command)
    }

    func count(of kind: BLECommandKind) -> Int {
        received.filter { $0 == kind }.count
    }
}

// MARK: - 검증 헬퍼

@MainActor
final class Checker {
    private(set) var passed = 0
    private(set) var failed = 0

    func check(_ condition: Bool, _ message: String) {
        if condition {
            passed += 1
            print("  ✅ \(message)")
        } else {
            failed += 1
            print("  ❌ FAIL: \(message)")
        }
    }
}

func settle(_ seconds: Double = 0.3) async {
    try? await Task.sleep(for: .seconds(seconds))
}

// MARK: - 월드 (iPhone 스택 + 가상 워치 5대)

@MainActor
final class World {
    let transport: iPhoneBLEPeripheralManager
    let watchCommandManager: WatchCommandManager
    let homeKit = HomeKitLightManager()
    let bleViewModel: BLEViewModel
    let agents: [WatchAgent]

    init(agentCount: Int = 5) {
        transport = iPhoneBLEPeripheralManager()
        watchCommandManager = WatchCommandManager(peripheralManager: transport)

        let lobby = MafiaGame(
            players: [],
            initialState: WaitingState(),
            homeKitLightManager: homeKit,
            watchCommandManager: watchCommandManager
        )

        bleViewModel = BLEViewModel(
            game: lobby,
            peripheralManager: transport,
            watchCommandManager: watchCommandManager
        )

        agents = (1...agentCount).map { WatchAgent(name: "W\($0)") }

        let agents = self.agents
        transport.onCommand = { command, centralID in
            Task { @MainActor in
                if let centralID {
                    agents.first { $0.id == centralID }?.receive(command)
                } else {
                    for agent in agents { agent.receive(command) }
                }
            }
        }
    }

    func joinAll() async {
        for agent in agents {
            transport.inject(.watchConnected(id: agent.id))
            await settle(0.1)
        }
        await settle(2.3) // connectionSucceeded → 2초 후 waiting 전환
    }

    /// GameView.startGameIfNeeded와 동일 로직
    func startGame() async -> MafiaGame {
        let game = MafiaGame(
            players: bleViewModel.connectedPlayers,
            initialState: WaitingState(),
            homeKitLightManager: homeKit,
            watchCommandManager: watchCommandManager
        )
        bleViewModel.game = game
        game.handleAction(.startGame)
        await settle(0.5)
        return game
    }

    func agent(for player: Player) -> WatchAgent {
        agents.first { $0.id.uuidString == player.watchId }!
    }

    func number(of player: Player, in game: MafiaGame) -> UInt8 {
        UInt8(game.players.firstIndex { $0.id == player.id }! + 1)
    }

    func answer(_ player: Player, _ answer: BLEAnswer) {
        bleViewModel.receiveAnswer(from: agent(for: player).id, answer: answer)
    }

    func reconnect(_ player: Player) async {
        transport.inject(.watchDisconnected(id: agent(for: player).id))
        await settle(0.15)
        transport.inject(.watchConnected(id: agent(for: player).id))
        await settle(0.3)
    }
}

// MARK: - 진입점

@main
enum FlowSim {
    @MainActor
    static func main() async {
        let checker = Checker()

        await scenario1_happyPath(checker)
        await scenario2_threeRounds(checker)
        await scenario3_timeoutsAndRace(checker)
        scenario4_commandQueue(checker)
        await scenario5_sixthWatch(checker)

        print("\n==========================================================")
        print("  통과 \(checker.passed) / 실패 \(checker.failed)")
        print("==========================================================\n")

        exit(checker.failed == 0 ? 0 : 1)
    }
}

// MARK: - 시나리오 1: 해피 패스 (시민 승리 + 재게임)

@MainActor
func scenario1_happyPath(_ checker: Checker) async {
    print("\n========== 시나리오 1: 해피 패스 — 시민 승리 + 재게임 ==========")
    GameTime.useActionDrivenTimes()
    GameAudioManager.shared.reset()
    func check(_ c: Bool, _ m: String) { checker.check(c, m) }

    let world = World()
    print("── 1-1. 참가하기: 워치 5대 연결 ──")
    await world.joinAll()

    check(world.bleViewModel.connectedPlayers.count == 5, "iPhone이 워치 5대를 등록")
    for agent in world.agents {
        check(agent.count(of: .connectionSucceeded) == 1,
              "\(agent.name): connectionSucceeded 1회 수신 (타깃 전송)")
        check(agent.store.currentScreen == .waiting, "\(agent.name): 대기 화면 진입")
    }
    check(world.agents[0].store.waitingCount == 5, "대기 인원 표시 5/5")

    print("── 1-2. 게임 시작 → 역할 배정 ──")
    let game = await world.startGame()
    check(game.currentState is RoleAssigningState, "RoleAssigningState 진입")

    for player in game.players {
        let a = world.agent(for: player)
        check(a.store.role == player.role,
              "\(a.name): 자기 역할(\(player.role!.displayName)) 수신")
        check(a.count(of: .roleResult) == 1, "\(a.name): roleResult 1회 (타깃 전송)")
        check(a.store.players.map(\.color) == game.players.map { $0.color },
              "\(a.name): 색상 명단 순서 일치")
    }

    print("── 1-3. 자기소개 → 마피아의 밤 ──")
    await settle(1.4)
    check(game.currentState is IntroductionState, "IntroductionState 진입")
    check(world.agents.allSatisfy { $0.store.currentScreen == .dayTime }, "전원 낮 화면")

    await settle(1.4)
    check(game.currentState is MafiaState, "MafiaState 진입")

    let mafia = game.players.first { $0.role == .mafia }!
    let police = game.players.first { $0.role == .police }!
    let doctor = game.players.first { $0.role == .doctor }!
    let citizens = game.players.filter { $0.role == .citizen }
    let victim = citizens[0]

    check(world.agent(for: mafia).store.currentScreen == .mafiaTurn, "마피아 워치만 지목 화면")
    check(game.players.filter { $0.id != mafia.id }
        .allSatisfy { world.agent(for: $0).store.currentScreen == .nightTime },
          "나머지 워치는 밤 대기 화면")

    world.answer(police, .mafiaSelected(playerID: world.number(of: victim, in: game)))
    await settle(0.2)
    check(game.mafiaTarget == nil, "비마피아의 마피아 지목 거부 (스푸핑 차단)")
    check(game.currentState is MafiaState, "거부 후에도 MafiaState 유지")

    world.answer(mafia, .mafiaSelected(playerID: world.number(of: victim, in: game)))
    await settle(0.5)

    print("── 1-4. 경찰의 밤 ──")
    check(game.currentState is PoliceState, "PoliceState 진입")
    check(world.agent(for: police).store.currentScreen == .policeTurn, "경찰 워치만 수사 화면")

    world.answer(police, .policeSelected(playerID: world.number(of: mafia, in: game)))
    await settle(0.5)

    check(world.agent(for: police).count(of: .policeResult) == 1, "경찰만 수사 결과 수신")
    check(world.agents.filter { $0.count(of: .policeResult) > 0 }.count == 1,
          "수사 결과가 다른 워치에 비노출")
    check(world.agent(for: police).store.policeResultIsMafia, "수사 결과: 마피아 맞음")

    print("── 1-5. 의사의 밤 → 토론(사망 발표) ──")
    check(game.currentState is DoctorState, "DoctorState 진입")
    check(world.agent(for: doctor).store.currentScreen == .doctorTurn, "의사 워치만 치료 화면")

    world.answer(doctor, .doctorSelected(playerID: world.number(of: police, in: game)))
    await settle(0.5)

    check(game.currentState is DiscussionState, "DiscussionState 진입")
    check(!victim.isAlive, "밤 희생자 사망 처리")
    check(world.agent(for: victim).store.currentScreen == .dead, "희생자 워치 사망자 플로우 진입")
    check(world.agent(for: victim).count(of: .playerRole) == game.players.count,
          "희생자 워치만 전체 직업 공개 수신")
    check(world.agents.filter { $0.count(of: .playerRole) > 0 }.count == 1,
          "직업 공개가 생존자에게 비노출")
    check(game.players.filter { $0.isAlive }
        .allSatisfy { world.agent(for: $0).store.currentScreen == .dayTime },
          "생존자 워치는 낮 화면")
    check(GameAudioManager.shared.playedNarrations
        .contains("discussionEnded-\(victim.color!.rawValue)Dead"),
          "사망 발표 나레이션 색상 정확")

    await world.reconnect(victim)
    check(world.agent(for: victim).store.currentScreen == .dead,
          "재연결한 사망자 워치가 사망자 플로우로 복원")

    print("── 1-6. 낮 투표 ──")
    await settle(1.2)
    check(game.currentState is VoteState, "VoteState 진입")

    world.answer(victim, .voteSubmitted(targetID: world.number(of: mafia, in: game)))
    await settle(0.1)
    check(game.currentState is VoteState, "사망자 투표는 집계되지 않음")

    // 재투표: 의사가 경찰→마피아로 변경 (마지막 표만 유효, 카운트 중복 없음)
    world.answer(doctor, .voteSubmitted(targetID: world.number(of: police, in: game)))
    await settle(0.1)
    world.answer(doctor, .voteSubmitted(targetID: world.number(of: mafia, in: game)))
    await settle(0.1)
    check(game.currentState is VoteState, "재투표는 표 수를 늘리지 않음 (조기 종료 안 됨)")

    for player in game.players.filter({ $0.isAlive && $0.id != doctor.id }) {
        let target = player.id == mafia.id ? police : mafia
        world.answer(player, .voteSubmitted(targetID: world.number(of: target, in: game)))
        await settle(0.05)
    }
    await settle(0.5)

    check(game.currentState is FinalDefenseState, "전원 투표 → 타임아웃 없이 조기 종료")
    check(game.finalDefensePlayer?.id == mafia.id, "최다 득표자 = 마피아")
    check(world.agent(for: victim).store.currentScreen == .dead, "투표/변론 화면이 사망자에게 비전달")

    print("── 1-7. 최후 변론 → 처형 ──")
    await settle(1.4)
    check(game.currentState is ExecutionVoteState, "ExecutionVoteState 진입")

    for player in game.players.filter({ $0.isAlive && $0.id != mafia.id }) {
        world.answer(player, .executionVoteSubmitted(isAgree: true))
        await settle(0.05)
    }
    await settle(0.4)

    check(game.currentState is ExecutionResultState, "전원 찬반 투표 → 조기 종료")
    check(world.agent(for: mafia).store.currentScreen == .executionResult, "처형 결과 화면 표시")
    check(world.agent(for: mafia).store.executionResult == .dead, "처형 결과 값 = 사망")

    print("── 1-8. 게임 종료 → 재게임 ──")
    await settle(1.4)

    check(game.currentState is ResultState, "ResultState 진입 (마피아 0 → 시민 승리)")
    check(game.winner == .citizens, "승자 = 시민")
    check(world.agents.allSatisfy { $0.store.currentScreen == .gameEnded },
          "전원(사망자 포함) 승리 화면 — 브로드캐스트")
    check(world.agents.allSatisfy { $0.store.winner == .citizens }, "워치 승자 표시 = 시민")

    game.handleAction(.gameEnded)
    let newLobby = MafiaGame(
        players: [],
        initialState: WaitingState(),
        homeKitLightManager: world.homeKit,
        watchCommandManager: world.watchCommandManager
    )
    world.bleViewModel.game = newLobby
    world.watchCommandManager.sendWaitingPlayers(count: world.bleViewModel.connectedPlayers.count)
    await settle(0.3)

    check(world.agents.allSatisfy { $0.store.currentScreen == .waiting },
          "재게임: 전 워치 대기 화면 자동 복귀")
    check(world.agents.allSatisfy { $0.store.players.isEmpty }, "재게임: 워치 상태 리셋")

    game.timerManager.stopTimer()
    newLobby.timerManager.stopTimer()
}

// MARK: - 시나리오 2: 3라운드 (마피아 승리, 2라운드 회귀 검증)

@MainActor
func scenario2_threeRounds(_ checker: Checker) async {
    print("\n========== 시나리오 2: 3라운드 — 부결/치료/리셋/죽은 직업자/마피아 승리 ==========")
    GameTime.useActionDrivenTimes()
    GameAudioManager.shared.reset()
    func check(_ c: Bool, _ m: String) { checker.check(c, m) }

    let world = World()
    await world.joinAll()
    check(world.bleViewModel.connectedPlayers.count == 5, "워치 5대 등록")

    let game = await world.startGame()
    await settle(1.4) // roleAssigning
    await settle(1.4) // introduction → Night → Mafia
    check(game.currentState is MafiaState, "1라운드 밤 진입")

    let mafia = game.players.first { $0.role == .mafia }!
    let police = game.players.first { $0.role == .police }!
    let doctor = game.players.first { $0.role == .doctor }!
    let citizens = game.players.filter { $0.role == .citizen }
    let c1 = citizens[0], c2 = citizens[1]
    func num(_ p: Player) -> UInt8 { world.number(of: p, in: game) }

    print("── 2-R1: 치료 성공 → 무사망 → 투표 → 처형 부결(생존) ──")
    world.answer(mafia, .mafiaSelected(playerID: num(c1)))
    await settle(0.4)
    world.answer(police, .policeSelected(playerID: num(c2)))
    await settle(0.4)
    check(world.agent(for: police).store.policeResultIsMafia == false, "시민 수사 결과 = 마피아 아님")
    world.answer(doctor, .doctorSelected(playerID: num(c1))) // 치료 성공!
    await settle(0.5)

    check(game.currentState is DiscussionState, "토론 진입")
    check(c1.isAlive, "치료 성공 — 희생자 생존")
    check(GameAudioManager.shared.playedNarrations.contains("discussionEnded-NobodyDead"),
          "무사망 나레이션 재생")
    check(world.agents.allSatisfy { $0.store.currentScreen == .dayTime }, "전원 낮 화면 (사망자 없음)")

    await settle(1.2) // discussion → Vote
    // m,p,d → c2 / c1 → m / c2 → m : 5표 전원 → c2 최다(3표)
    for (voter, target) in [(mafia, c2), (police, c2), (doctor, c2), (c1, mafia), (c2, mafia)] {
        world.answer(voter, .voteSubmitted(targetID: num(target)))
        await settle(0.05)
    }
    await settle(0.5)
    check(game.currentState is FinalDefenseState, "전원 투표 조기 종료")
    check(game.finalDefensePlayer?.id == c2.id, "최다 득표 = 시민2")

    // 재연결 복원: 최후 변론 중
    await world.reconnect(doctor)
    check(world.agent(for: doctor).store.currentScreen == .finalDefense,
          "재연결 워치가 최후 변론 화면으로 복원")

    await settle(1.4) // finalDefense → ExecutionVote
    // 찬성 1(마피아) vs 반대 3 → 부결
    let nightBgmBefore = GameAudioManager.shared.count(ofBgm: "nightBgm")
    for (voter, agree) in [(mafia, true), (police, false), (doctor, false), (c1, false)] {
        world.answer(voter, .executionVoteSubmitted(isAgree: agree))
        await settle(0.05)
    }
    await settle(0.4)
    check(game.currentState is ExecutionResultState, "전원 찬반 투표 조기 종료")
    check(world.agent(for: c2).store.executionResult == .survive, "처형 부결 → 생존 표시")

    await settle(1.4) // executionResult → 처형 적용(생존) → NightState 경유 → Mafia
    check(c2.isAlive, "부결로 시민2 생존")
    check(game.currentState is MafiaState, "2라운드 밤 진입")
    check(GameAudioManager.shared.count(ofBgm: "nightBgm") == nightBgmBefore + 1,
          "처형 후 NightState 경유 (밤 BGM 재생됨)")

    print("── 2-R2: 경찰 사망 → 발표 색상 → 의사 처형(투표 리셋 검증) ──")
    world.answer(mafia, .mafiaSelected(playerID: num(police)))
    await settle(0.4)
    world.answer(police, .policeSelected(playerID: num(mafia)))
    await settle(0.4)
    world.answer(doctor, .doctorSelected(playerID: num(c2))) // 빗나감
    await settle(0.5)

    check(game.currentState is DiscussionState, "2라운드 토론 진입")
    check(!police.isAlive, "경찰 사망")
    check(GameAudioManager.shared.playedNarrations.last { $0.hasSuffix("Dead") }
          == "discussionEnded-\(police.color!.rawValue)Dead",
          "2라운드 사망 발표 = 이번 밤 희생자 색 (이전 라운드 아님)")
    check(world.agent(for: police).store.currentScreen == .dead, "죽은 경찰 워치 사망자 플로우")

    await settle(1.2) // → Vote
    // m,c1,c2 → doctor / doctor → m : 4표 전원 → doctor 최다(3표)
    for (voter, target) in [(mafia, doctor), (c1, doctor), (c2, doctor), (doctor, mafia)] {
        world.answer(voter, .voteSubmitted(targetID: num(target)))
        await settle(0.05)
    }
    await settle(0.5)
    check(game.finalDefensePlayer?.id == doctor.id, "최다 득표 = 의사")

    await settle(1.4) // → ExecutionVote
    // 찬성 2(m,c1) vs 반대 1(c2) → 가결 — 1라운드 표가 남아 있으면 부결로 뒤집힘
    for (voter, agree) in [(mafia, true), (c1, true), (c2, false)] {
        world.answer(voter, .executionVoteSubmitted(isAgree: agree))
        await settle(0.05)
    }
    await settle(0.4)
    check(game.currentState is ExecutionResultState, "찬반 투표 조기 종료")
    check(world.agent(for: doctor).store.executionResult == .dead,
          "의사 처형 가결 — 라운드 간 찬반 투표 리셋 검증")

    await settle(1.4) // → 처형 적용 → NightState → Mafia
    check(!doctor.isAlive, "의사 처형됨")
    check(game.currentState is MafiaState, "3라운드 밤 진입")

    print("── 2-R3: 죽은 직업자 페이즈 타임아웃 → 마피아 승리 ──")
    // 경찰/의사가 죽었으므로 해당 페이즈는 타임아웃으로 진행
    GameTime.police = 1
    GameTime.doctor = 1

    let policeTurnBefore = world.agent(for: police).count(of: .policeTurn)
    let doctorTurnBefore = world.agent(for: doctor).count(of: .doctorTurn)

    // G2 검증: 이미 죽은 대상(경찰)을 지목하면 거부돼야 함
    world.answer(mafia, .mafiaSelected(playerID: num(police)))
    await settle(0.3)
    check(game.mafiaTarget == nil, "죽은 대상 지목은 거부됨 (target.isAlive 검증)")
    check(game.currentState is MafiaState, "거부 후에도 MafiaState 유지")

    world.answer(mafia, .mafiaSelected(playerID: num(c1)))
    await settle(0.4) // → PoliceState (1초 타임아웃 대기)
    await settle(1.4) // → DoctorState
    await settle(1.4) // → proceedAfterNight → c1 사망 → 1:1 → 마피아 승리

    check(world.agent(for: police).count(of: .policeTurn) == policeTurnBefore,
          "죽은 경찰에게 수사 턴 비전달")
    check(world.agent(for: doctor).count(of: .doctorTurn) == doctorTurnBefore,
          "죽은 의사에게 치료 턴 비전달")
    check(!c1.isAlive, "3라운드 희생자 사망")
    check(game.currentState is ResultState, "마피아 1 : 시민 1 → 게임 종료")
    check(game.winner == .mafia, "승자 = 마피아")
    check(world.agents.allSatisfy { $0.store.currentScreen == .gameEnded },
          "전원(사망자 3명 포함) 승리 화면 수신")
    check(world.agents.allSatisfy { $0.store.winner == .mafia }, "워치 승자 표시 = 마피아")

    // 결과 화면에서 재연결 → 승리 화면 복원
    await world.reconnect(c2)
    check(world.agent(for: c2).store.currentScreen == .gameEnded,
          "결과 화면에서 재연결 시 승리 화면 복원")

    game.timerManager.stopTimer()
}

// MARK: - 시나리오 3: 타임아웃 풀사이클 + 이중 전이 레이스

@MainActor
func scenario3_timeoutsAndRace(_ checker: Checker) async {
    print("\n========== 시나리오 3: 타임아웃 풀사이클 + 이중 전이 레이스 ==========")
    func check(_ c: Bool, _ m: String) { checker.check(c, m) }

    // 3-A: 아무도 행동하지 않는 한 사이클 (전부 타임아웃)
    GameTime.useAllShortTimes()
    GameAudioManager.shared.reset()

    let world = World()
    await world.joinAll()
    let game = await world.startGame()

    // role(1)→intro(1)→mafia(1,무지목)→police(1)→doctor(1)→discussion(1,무사망)→vote(1,무투표)→Night→Mafia…
    // 1초 타이머라 사이클이 계속 돌므로, 특정 시점 상태 대신 "밤이 2회 이상 시작됨"으로 검증
    await settle(9.5)

    check(GameAudioManager.shared.count(ofNarration: "mafiaSelected") >= 2,
          "전 페이즈 타임아웃으로 사이클이 다시 밤으로 복귀")
    check(game.players.allSatisfy { $0.isAlive }, "무지목 밤 — 전원 생존")
    check(GameAudioManager.shared.playedNarrations.contains("discussionEnded-NobodyDead"),
          "무사망 발표")
    check(GameAudioManager.shared.playedNarrations.contains("voteCompleted-noVotes"),
          "무투표 처리")

    game.timerManager.stopTimer()

    // 3-B: 이중 전이 레이스 — 같은 답이 연속 2번 도착해도 전이는 1번
    GameTime.useActionDrivenTimes()
    GameAudioManager.shared.reset()

    let world2 = World()
    await world2.joinAll()
    let game2 = await world2.startGame()
    await settle(1.4)
    await settle(1.4)
    check(game2.currentState is MafiaState, "레이스 테스트: 밤 진입")

    let mafia2 = game2.players.first { $0.role == .mafia }!
    let target2 = game2.players.first { $0.role == .citizen }!

    let policeStartBefore = GameAudioManager.shared.count(ofNarration: "policeSelected")

    // 나레이션 대기(50ms) 안에 두 번째 지목이 도착하는 상황
    world2.answer(mafia2, .mafiaSelected(playerID: world2.number(of: target2, in: game2)))
    world2.answer(mafia2, .mafiaSelected(playerID: world2.number(of: target2, in: game2)))
    await settle(0.6)

    check(game2.currentState is PoliceState, "중복 지목 후 PoliceState 정상 진입")
    check(GameAudioManager.shared.count(ofNarration: "policeSelected") == policeStartBefore + 1,
          "이중 전이 차단 — 경찰 페이즈는 한 번만 시작됨")

    game2.timerManager.stopTimer()
}

// MARK: - 시나리오 5: 6번째 워치 난입 (정원 초과 거절)

@MainActor
func scenario5_sixthWatch(_ checker: Checker) async {
    print("\n========== 시나리오 5: 6번째 워치 난입 — 정원 초과 거절 ==========")
    GameTime.useActionDrivenTimes()
    GameAudioManager.shared.reset()
    func check(_ c: Bool, _ m: String) { checker.check(c, m) }

    let world = World(agentCount: 6)

    // 앞 5대만 조인
    for agent in world.agents.prefix(5) {
        world.transport.inject(.watchConnected(id: agent.id))
        await settle(0.1)
    }
    await settle(2.3)
    check(world.bleViewModel.connectedPlayers.count == 5, "정원 5대 등록")

    // 6번째 조인 시도 → 거절
    let sixth = world.agents[5]
    world.transport.inject(.watchConnected(id: sixth.id))
    await settle(0.4)

    check(world.bleViewModel.connectedPlayers.count == 5, "6번째는 등록되지 않음 — 로비 정지 없음")
    check(sixth.count(of: .connectionFailed) == 1, "6번째 워치에 connectionFailed 통지")
    check(sixth.store.currentScreen == .connectionFailed, "6번째 워치 연결 실패 화면 표시")

    // 재시도해도 거절
    world.transport.inject(.watchDisconnected(id: sixth.id))
    await settle(0.2)
    world.transport.inject(.watchConnected(id: sixth.id))
    await settle(0.4)
    check(world.bleViewModel.connectedPlayers.count == 5, "재시도 후에도 정원 유지")
    check(sixth.count(of: .connectionFailed) == 2, "재시도에도 다시 거절 통지")

    // 게임은 5명으로 정상 시작, 거절된 워치는 게임 화면 미수신
    let game = await world.startGame()
    check(game.currentState is RoleAssigningState, "5명으로 게임 정상 시작")
    check(sixth.count(of: .roleAssigning) == 0, "거절된 워치에 게임 화면 미전송")
    check(world.agents.prefix(5).allSatisfy { $0.count(of: .roleAssigning) == 1 },
          "참가자 5명만 역할 배정 수신")

    game.timerManager.stopTimer()
}

// MARK: - 시나리오 4: BLE 재전송 큐 (실제 BLECommandQueue)

@MainActor
func scenario4_commandQueue(_ checker: Checker) {
    print("\n========== 시나리오 4: BLE 재전송 큐 — 큐 가득/순서 보장 ==========")
    func check(_ c: Bool, _ m: String) { checker.check(c, m) }

    let queue = BLECommandQueue()
    var delivered: [String] = []
    var allowSend = true

    let sender: BLECommandQueue.Send = { entry in
        guard allowSend else { return false }
        delivered.append(entry.label)
        return true
    }

    func entry(_ label: String) -> BLECommandQueue.Entry {
        BLECommandQueue.Entry(data: Data([0, 0, 0]), centralID: nil, label: label)
    }

    // 정상 전송
    queue.send(entry("A"), using: sender)
    check(delivered == ["A"] && queue.pending.isEmpty, "정상 전송 — 큐 비어 있음")

    // 큐 가득(updateValue false) 상황: B~D 유실 없이 보관
    allowSend = false
    queue.send(entry("B"), using: sender)
    queue.send(entry("C"), using: sender)
    allowSend = true
    queue.send(entry("D"), using: sender) // 대기 중이면 성공 가능해도 순서 보장 위해 뒤에 줄
    check(queue.pending.map(\.label) == ["B", "C", "D"], "실패 명령 보관 + 후속 명령 순서 유지")
    check(delivered == ["A"], "대기 중에는 새 명령이 추월하지 않음")

    // 자리 생김(peripheralManagerIsReady) → 순서대로 재전송
    queue.flush(using: sender)
    check(delivered == ["A", "B", "C", "D"], "flush 시 원래 순서로 재전송")
    check(queue.pending.isEmpty, "flush 후 큐 비어 있음")

    // 부분 flush: 중간에 다시 가득 차면 남은 항목 보존
    allowSend = false
    queue.send(entry("E"), using: sender)
    queue.send(entry("F"), using: sender)
    allowSend = true
    var sentOnce = false
    queue.flush { e in
        if sentOnce { return false } // E만 성공, F에서 다시 가득
        sentOnce = true
        delivered.append(e.label)
        return true
    }
    check(delivered.last == "E" && queue.pending.map(\.label) == ["F"],
          "부분 flush — 실패 항목부터 보존")

    queue.flush(using: sender)
    check(delivered.last == "F" && queue.pending.isEmpty, "재flush로 잔여 항목 전송")

    // 전원 사이클 시 폐기
    allowSend = false
    queue.send(entry("G"), using: sender)
    queue.removeAll()
    check(queue.pending.isEmpty, "전원 사이클 시 잔여 큐 폐기")
}
