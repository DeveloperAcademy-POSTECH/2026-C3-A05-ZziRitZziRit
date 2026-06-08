//
//  ResultManager.swift
//  Mayoty
//
//  Created by sun on 6/4/26.
//

final class ResultManager {

    func checkWinner(players: [Player]) -> Team? {
        let alivePlayers = players.filter { $0.isAlive }

        let mafiaCount = alivePlayers.filter {
            $0.role?.team == .mafia
        }.count

        let citizenCount = alivePlayers.count - mafiaCount

        if mafiaCount == 0 {
            return .citizens
        }

        if mafiaCount == citizenCount {
            return .mafia
        }

        return nil
    }
}
