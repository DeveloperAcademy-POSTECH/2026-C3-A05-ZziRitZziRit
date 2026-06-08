//
//  MafiaGame.swift
//  Mayoty
//
//  Created by sun on 6/2/26.
//

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

    private(set) var finalDefensePlayer: Player?
    private(set) var winner: Team?

    let voteManager = VoteManager()
    let timerManager = TimerManager()
    let gameRuleManager = GameRuleManager()
    let resultManager = ResultManager()
    
    let roleManager = RoleManager()
    let colorManager = ColorManager()
    let lightManager: LightManager

    init(
        players: [Player],
        initialState: any GameState,
        homeKitLightManager: HomeKitLightManager
    ) {
        self.players = players
        self.currentState = initialState
        self.lightManager = LightManager(
            homeKitLightManager: homeKitLightManager
        )

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
        GameLogger.stateChanged(
            from: currentState,
            to: state
        )

        currentState = state
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


