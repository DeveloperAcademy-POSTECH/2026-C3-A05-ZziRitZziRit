//
//  MafiaGame.swift
//  Mayoty
//
//  Created by sun on 6/2/26.
//

import Foundation
import Observation

@Observable
final class MafiaGame {
    private(set) var players: [Player]

    private(set) var currentState: any GameState {
        willSet {
            currentState.exit(game: self)
        }
        didSet {
            currentState.enter(game: self)
        }
    }

    private(set) var mafiaTarget: Player?
    private(set) var policeTarget: Player?
    private(set) var doctorTarget: Player?

    /// 직전 밤에 실제로 사망한 플레이어 — 토론 시작 사망자 발표용
    private(set) var lastNightVictim: Player?

    private(set) var finalDefensePlayer: Player?
    private(set) var winner: Team?

    /// 나레이션 대기 후 전이의 중복 실행 방지 토큰
    /// (타임아웃과 BLE 액션이 겹쳐도 전이는 한 번만)
    private var narrationToken: UUID?

    let voteManager = VoteManager()
    let timerManager = TimerManager()
    let gameRuleManager = GameRuleManager()
    let resultManager = ResultManager()

    let roleManager = RoleManager()
    let colorManager = ColorManager()
    let lightManager: LightManager
    let soundManager = SoundManager()
    let watchCommandManager: WatchCommandManager

    init(
        players: [Player],
        initialState: any GameState,
        homeKitLightManager: HomeKitLightManager,
        watchCommandManager: WatchCommandManager
    ) {
        self.players = players
        self.currentState = initialState
        self.lightManager = LightManager(
            homeKitLightManager: homeKitLightManager
        )
        self.watchCommandManager = watchCommandManager

        self.currentState.enter(game: self)
    }

    func handleAction(_ action: GameAction) {
        GameLogger.action(action)

        currentState.handleAction(
            game: self,
            action: action
        )
    }

    func changeState(to state: any GameState) {
        // 다른 경로의 전이가 일어나면 대기 중이던 나레이션 후 전이는 무효
        narrationToken = nil

        GameLogger.stateChanged(
            from: currentState,
            to: state
        )

        currentState = state
    }

    /// 나레이션 재생을 기다린 뒤 액션 실행. 이미 대기 중인 나레이션이 있거나
    /// 대기 중 상태가 바뀌면 실행하지 않음 — 이중 전이 방지
    func runAfterNarration(
        _ narration: @escaping () async -> Void,
        then action: @escaping () -> Void
    ) {
        guard narrationToken == nil else {
            GameLogger.event("⏳ 나레이션 대기 중 — 중복 전이 무시")
            return
        }

        let token = UUID()
        narrationToken = token

        let fromStateType = ObjectIdentifier(type(of: currentState))

        Task { [weak self] in
            await narration()

            guard let self, self.narrationToken == token else { return }

            self.narrationToken = nil

            guard ObjectIdentifier(type(of: self.currentState)) == fromStateType else {
                GameLogger.event("⏳ 나레이션 중 상태 변경됨 — stale 전이 차단")
                return
            }

            action()
        }
    }

    func selectMafiaTarget(_ player: Player) {
        mafiaTarget = player
    }

    func selectInvestigateTarget(_ player: Player) {
        policeTarget = player
    }

    func selectHealTarget(_ player: Player) {
        doctorTarget = player
    }

    func resetNightTargets() {
        mafiaTarget = nil
        policeTarget = nil
        doctorTarget = nil
    }

    func setLastNightVictim(_ player: Player?) {
        lastNightVictim = player
    }

    func selectFinalDefensePlayer(_ player: Player) {
        finalDefensePlayer = player
    }

    func resetFinalDefensePlayer() {
        finalDefensePlayer = nil
    }

    func proceedAfterNight() {
        gameRuleManager.applyNightResult(game: self)
        currentState.proceedAfterNight(game: self)
    }

    func proceedAfterExecution() {
        gameRuleManager.applyExecutionResult(game: self)
        currentState.proceedAfterExecution(game: self)
    }

    func setWinner(_ winner: Team) {
        self.winner = winner
    }

    func endGame() {
        handleAction(.gameEnded)
    }
}
