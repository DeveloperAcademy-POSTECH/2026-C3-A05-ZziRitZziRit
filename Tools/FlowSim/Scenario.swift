//
//  main.swift — Mayoty 멀티워치 풀게임 시뮬레이션
//
//  가상 워치 5대가 실제 프로덕션 코드(MafiaGame/상태머신/BLEViewModel/
//  WatchCommandManager/WatchCommandStore)를 통해 한 판을 끝까지 플레이한다.
//  전송 계층만 인메모리 스텁 — BLECommand는 Data 인코딩/디코딩을 왕복한다.
//

import Foundation

// MARK: - 가상 워치

@MainActor
final class WatchAgent {
    let id = UUID()
    let name: String
    let store = WatchCommandStore()

    /// 수신한 명령 종류 기록 (타깃 전송 검증용)
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

// MARK: - 시나리오

@main
enum FlowSim {
    @MainActor
    static func main() async {
        let checker = Checker()
        func check(_ c: Bool, _ m: String) { checker.check(c, m) }

        print("\n================ Mayoty FlowSim — 워치 5대 풀게임 시뮬레이션 ================\n")

        // ── 셋업: iPhone 측 실제 스택 (전송만 스텁) ──
        let transport = iPhoneBLEPeripheralManager()
        let watchCommandManager = WatchCommandManager(peripheralManager: transport)
        let homeKit = HomeKitLightManager()

        let lobbyGame = MafiaGame(
            players: [],
            initialState: WaitingState(),
            homeKitLightManager: homeKit,
            watchCommandManager: watchCommandManager
        )

        let bleViewModel = BLEViewModel(
            game: lobbyGame,
            peripheralManager: transport,
            watchCommandManager: watchCommandManager
        )

        let agents = [
            WatchAgent(name: "W1"), WatchAgent(name: "W2"), WatchAgent(name: "W3"),
            WatchAgent(name: "W4"), WatchAgent(name: "W5")
        ]

        // 전송 허브: 타깃 지정이면 해당 워치만, nil이면 브로드캐스트
        transport.onCommand = { command, centralID in
            Task { @MainActor in
                if let centralID {
                    agents.first { $0.id == centralID }?.receive(command)
                } else {
                    for agent in agents { agent.receive(command) }
                }
            }
        }

        // ── 1. 참가(조인): 워치 5대 구독 ──
        print("── 1. 참가하기: 워치 5대 연결 ──")

        for agent in agents {
            transport.inject(.watchConnected(id: agent.id))
            await settle(0.15)
        }
        await settle(2.3) // connectionSucceeded → 2초 후 waiting 전환 대기

        check(bleViewModel.connectedPlayers.count == 5, "iPhone이 워치 5대를 등록")
        for agent in agents {
            check(agent.count(of: .connectionSucceeded) == 1,
                  "\(agent.name): connectionSucceeded를 정확히 1회 수신 (타깃 전송)")
            check(agent.store.currentScreen == .waiting, "\(agent.name): 대기 화면 진입")
        }
        check(agents[0].store.waitingCount == 5, "대기 인원 표시 5/5")

        // ── 2. 게임 시작 (GameView.startGameIfNeeded와 동일 로직) ──
        print("\n── 2. 게임 시작 → 역할 배정 ──")

        let game = MafiaGame(
            players: bleViewModel.connectedPlayers,
            initialState: WaitingState(),
            homeKitLightManager: homeKit,
            watchCommandManager: watchCommandManager
        )
        bleViewModel.game = game
        game.handleAction(.startGame)

        await settle(0.5) // startGame 나레이션 → RoleAssigning 진입

        check(game.currentState is RoleAssigningState, "RoleAssigningState 진입")

        func agent(for player: Player) -> WatchAgent {
            agents.first { $0.id.uuidString == player.watchId }!
        }
        func number(of player: Player) -> UInt8 {
            UInt8(game.players.firstIndex { $0.id == player.id }! + 1)
        }

        for player in game.players {
            let a = agent(for: player)
            check(a.store.role == player.role,
                  "\(a.name): 자기 역할(\(player.role!.displayName))을 정확히 수신")
            check(a.count(of: .roleResult) == 1,
                  "\(a.name): roleResult를 정확히 1회 수신 (타깃 전송)")
            check(a.store.players.map(\.color) == game.players.map { $0.color },
                  "\(a.name): 플레이어 색상 명단이 호스트와 동일한 순서")
        }

        // ── 3. 자기소개 → 밤 → 마피아 턴 ──
        print("\n── 3. 자기소개 → 마피아의 밤 ──")
        await settle(1.4) // roleAssigning 타이머(1s)

        check(game.currentState is IntroductionState, "IntroductionState 진입")
        check(agents.allSatisfy { $0.store.currentScreen == .dayTime }, "전원 낮 화면")

        await settle(1.4) // introduction 타이머(1s) → NightState → MafiaState
        check(game.currentState is MafiaState, "MafiaState 진입")

        let mafia = game.players.first { $0.role == .mafia }!
        let police = game.players.first { $0.role == .police }!
        let doctor = game.players.first { $0.role == .doctor }!
        let citizens = game.players.filter { $0.role == .citizen }
        let victim = citizens[0]

        check(agent(for: mafia).store.currentScreen == .mafiaTurn, "마피아 워치만 지목 화면")
        check(game.players.filter { $0.id != mafia.id }
            .allSatisfy { agent(for: $0).store.currentScreen == .nightTime },
              "나머지 워치는 밤 대기 화면")

        // 발신자 검증: 경찰 워치가 마피아 지목을 보내면 거부돼야 함
        bleViewModel.receiveAnswer(
            from: agent(for: police).id,
            answer: .mafiaSelected(playerID: number(of: victim))
        )
        await settle(0.2)
        check(game.mafiaTarget == nil, "비마피아의 마피아 지목은 거부됨 (스푸핑 차단)")
        check(game.currentState is MafiaState, "거부 후에도 MafiaState 유지")

        // 마피아가 시민을 지목
        bleViewModel.receiveAnswer(
            from: agent(for: mafia).id,
            answer: .mafiaSelected(playerID: number(of: victim))
        )
        await settle(0.5)

        // ── 4. 경찰의 밤 ──
        print("\n── 4. 경찰의 밤 ──")
        check(game.currentState is PoliceState, "PoliceState 진입")
        check(agent(for: police).store.currentScreen == .policeTurn, "경찰 워치만 수사 화면")

        bleViewModel.receiveAnswer(
            from: agent(for: police).id,
            answer: .policeSelected(playerID: number(of: mafia))
        )
        await settle(0.5)

        check(agent(for: police).count(of: .policeResult) == 1, "경찰만 수사 결과 수신")
        check(agents.filter { $0.count(of: .policeResult) > 0 }.count == 1,
              "수사 결과가 다른 워치에 노출되지 않음")
        check(agent(for: police).store.policeResultIsMafia, "수사 결과: 마피아 맞음")

        // ── 5. 의사의 밤 → 사망 발표 ──
        print("\n── 5. 의사의 밤 → 토론(사망 발표) ──")
        check(game.currentState is DoctorState, "DoctorState 진입")
        check(agent(for: doctor).store.currentScreen == .doctorTurn, "의사 워치만 치료 화면")

        bleViewModel.receiveAnswer(
            from: agent(for: doctor).id,
            answer: .doctorSelected(playerID: number(of: police)) // 희생자 못 살림
        )
        await settle(0.5)

        check(game.currentState is DiscussionState, "DiscussionState 진입")
        check(!victim.isAlive, "밤 희생자 사망 처리")
        check(agent(for: victim).store.currentScreen == .dead, "희생자 워치는 사망자 플로우 진입")
        check(agent(for: victim).count(of: .playerRole) == game.players.count,
              "희생자 워치만 전체 직업 공개 수신")
        check(agents.filter { $0.count(of: .playerRole) > 0 }.count == 1,
              "직업 공개가 생존자에게 노출되지 않음")
        check(game.players.filter { $0.isAlive }
            .allSatisfy { agent(for: $0).store.currentScreen == .dayTime },
              "생존자 워치는 낮 화면")
        check(GameAudioManager.shared.playedNarrations
            .contains("discussionEnded-\(victim.color!.rawValue)Dead"),
              "사망 발표 나레이션이 정확한 희생자 색상")

        // 재연결 복원: 죽은 워치가 끊겼다 돌아오면 사망자 플로우로 복원
        transport.inject(.watchDisconnected(id: agent(for: victim).id))
        await settle(0.2)
        transport.inject(.watchConnected(id: agent(for: victim).id))
        await settle(0.3)
        check(agent(for: victim).store.currentScreen == .dead, "재연결한 사망자 워치가 사망자 플로우로 복원")

        // ── 6. 투표 (전원 투표 조기 종료 + 사망자 투표 차단) ──
        print("\n── 6. 낮 투표 ──")
        await settle(1.2) // discussion 타이머(1s)
        check(game.currentState is VoteState, "VoteState 진입")

        // 죽은 희생자의 투표는 무시돼야 함
        bleViewModel.receiveAnswer(
            from: agent(for: victim).id,
            answer: .voteSubmitted(targetID: number(of: mafia))
        )
        await settle(0.1)
        check(game.currentState is VoteState, "사망자 투표는 집계되지 않음")

        // 생존자 4명 전원 투표(마피아는 자기 투표 불가 → 경찰에게) → 조기 종료
        for player in game.players.filter({ $0.isAlive }) {
            let target = player.id == mafia.id ? police : mafia

            bleViewModel.receiveAnswer(
                from: agent(for: player).id,
                answer: .voteSubmitted(targetID: number(of: target))
            )
            await settle(0.05)
        }
        await settle(0.5)

        check(game.currentState is FinalDefenseState, "전원 투표 → 타임아웃 없이 조기 종료")
        check(game.finalDefensePlayer?.id == mafia.id, "최다 득표자 = 마피아")
        check(agent(for: victim).store.currentScreen == .dead, "투표 화면이 사망자에게 가지 않음")

        // ── 7. 최후 변론 → 찬반 투표 → 처형 ──
        print("\n── 7. 최후 변론 → 처형 ──")
        await settle(1.4) // finalDefense 타이머(1s)
        check(game.currentState is ExecutionVoteState, "ExecutionVoteState 진입")

        for player in game.players.filter({ $0.isAlive && $0.id != mafia.id }) {
            bleViewModel.receiveAnswer(
                from: agent(for: player).id,
                answer: .executionVoteSubmitted(isAgree: true)
            )
            await settle(0.05)
        }
        await settle(0.4)

        check(game.currentState is ExecutionResultState, "전원 찬반 투표 → 조기 종료")
        check(agent(for: mafia).store.currentScreen == .executionResult, "처형 결과 화면 표시")
        check(agent(for: mafia).store.executionResult == .dead, "처형 결과 값 = 사망 (하드코딩 아님)")

        // ── 8. 승리 → 재게임 ──
        print("\n── 8. 게임 종료 → 재게임 ──")
        await settle(1.4) // executionResult 타이머(1s) → 마피아 처형 → 시민 승리

        check(game.currentState is ResultState, "ResultState 진입 (마피아 0명 → 시민 승리)")
        check(game.winner == .citizens, "승자 = 시민")
        check(agents.allSatisfy { $0.store.currentScreen == .gameEnded },
              "전원(사망자 포함) 승리 화면 수신 — 브로드캐스트")
        check(agents.allSatisfy { $0.store.winner == .citizens }, "워치 승자 표시 = 시민")

        // iPhone의 '새 게임 시작' 버튼과 동일 로직
        game.handleAction(.gameEnded)
        let newLobby = MafiaGame(
            players: [],
            initialState: WaitingState(),
            homeKitLightManager: homeKit,
            watchCommandManager: watchCommandManager
        )
        bleViewModel.game = newLobby
        watchCommandManager.sendWaitingPlayers(count: bleViewModel.connectedPlayers.count)
        await settle(0.3)

        check(agents.allSatisfy { $0.store.currentScreen == .waiting },
              "재게임: 전 워치가 대기 화면으로 자동 복귀")
        check(agents.allSatisfy { $0.store.players.isEmpty }, "재게임: 워치 상태 리셋")

        // ── 결과 ──
        print("\n==========================================================")
        print("  통과 \(checker.passed) / 실패 \(checker.failed)")
        print("==========================================================\n")

        exit(checker.failed == 0 ? 0 : 1)
    }
}
