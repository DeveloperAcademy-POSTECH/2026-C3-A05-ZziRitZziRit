//
//  MafiaGame.swift
//  Mayoty
//
//  Created by sun on 6/2/26.
//

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

    init(
        players: [Player],
        initialState: any GameState
    ) {
        self.players = players
        self.currentState = initialState
        self.currentState.enter(game: self)
    }

    func handleAction(_ action: GameAction) {
        currentState.handleAction(
            game: self,
            action: action
        )
    }

    func changeState(to state: any GameState) {
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

        if let winner = resultManager.checkWinner(players: players) {
            self.winner = winner
            changeState(to: ResultState())
            return
        }

        changeState(to: DiscussionState())
    }

    func proceedAfterExecution() {
        gameRuleManager.applyExecutionResult(game: self)

        if let winner = resultManager.checkWinner(players: players) {
            self.winner = winner
            changeState(to: ResultState())
            return
        }

        changeState(to: NightState())
    }

    func endGame() {
        handleAction(.gameEnded)
    }
}
