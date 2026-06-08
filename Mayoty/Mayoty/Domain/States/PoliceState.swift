//
//  PoliceState.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

struct PoliceState: GameState {
    func enter(game: MafiaGame) {
        GameLogger.event("👮‍♂️ 경찰 수사 시작")
        
        game.timerManager.startTimer(
            seconds: GameTime.police,
            onTimeout: {
                GameLogger.timer("경찰 수사 시간 종료")
                game.changeState(to: DoctorState())
            }
        )
    }
    
    func handleAction(game: MafiaGame, action: GameAction) {
        guard case .policeSelected(let target) = action else { return }
        
        game.selectInvestigateTarget(target)
        
        let isMafia = target.role?.team == .mafia
        
        GameLogger.event(
            "👮‍♂️ 경찰 수사 완료: \(isMafia ? "마피아" : "시민")"
        )
        
        // TODO: 경찰 워치에 수사 결과 전송
        // game.watchBluetoothManager.sendInvestigationResult(isMafia)
        game.changeState(to: DoctorState())
    }
    
    func exit(game: MafiaGame) {
        GameLogger.event("👮‍♂️ 경찰 수사 종료")
        game.timerManager.stopTimer()
    }
}
