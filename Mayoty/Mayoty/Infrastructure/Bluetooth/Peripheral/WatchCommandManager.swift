//
//  WatchCommandManager.swift
//  Mayoty
//
//  Created by sun on 6/11/26.
//

import Foundation

final class WatchCommandManager {
    private let peripheralManager: iPhoneBLEPeripheralManager

    init(peripheralManager: iPhoneBLEPeripheralManager) {
        self.peripheralManager = peripheralManager
    }

    func send(_ command: BLECommand) {
        peripheralManager.sendCommand(command)
    }

    func sendRoleAssigning() {
        send(.roleAssigning())
    }

    func sendRoleResults(to players: [Player]) {
        forEachPlayer(players) { player, targetID in
            guard let role = player.role else { return }

            send(.roleResult(
                targetID: targetID,
                role: role
            ))
        }
    }

    func sendDayTime() {
        send(.dayTime())
    }

    func sendMafiaTurn(to players: [Player]) {
        sendRoleTurn(
            to: players,
            activeRole: .mafia,
            activeKind: .mafiaTurn
        )
    }

    func sendPoliceTurn(to players: [Player]) {
        sendRoleTurn(
            to: players,
            activeRole: .police,
            activeKind: .policeTurn
        )
    }

    func sendDoctorTurn(to players: [Player]) {
        sendRoleTurn(
            to: players,
            activeRole: .doctor,
            activeKind: .doctorTurn
        )
    }

    func sendPoliceResult(
        isMafia: Bool,
        to players: [Player]
    ) {
        guard let policeTargetID = targetID(
            for: .police,
            in: players
        ) else { return }

        send(.policeResult(
            targetID: policeTargetID,
            isMafia: isMafia
        ))
    }

    func sendVote() {
        send(.vote())
    }

    func sendFinalDefense() {
        send(.finalDefense())
    }

    func sendExecutionVote() {
        send(.executionVote())
    }

    func sendExecutionResult() {
        send(.init(kind: .executionResult))
    }
    
    func sendGameEnded(winner: Team) {
        send(.gameEnded(winner: winner))
    }

    func sendGameEnded(winner: Team?) {
        send(.init(
            kind: .gameEnded,
            value: winner?.bleValue ?? 0
        ))
    }
    
    func sendPlayerColors(to players: [Player]) {
        for (index, player) in players.enumerated() {
            guard let color = player.color else { continue }

            send(
                BLECommand(
                    kind: .playerColor,
                    targetID: UInt8(index + 1),
                    value: color.bleValue
                )
            )
        }
    }
}

// MARK: - Private Helpers

private extension WatchCommandManager {
    func sendRoleTurn(
        to players: [Player],
        activeRole: Role,
        activeKind: BLECommandKind
    ) {
        forEachPlayer(players) { player, targetID in
            if player.role == activeRole {
                send(
                    BLECommand(
                        kind: activeKind,
                        targetID: targetID
                    )
                )
            } else {
                send(.nightWaiting(targetID: targetID))
            }
        }
    }

    func forEachPlayer(
        _ players: [Player],
        action: (Player, UInt8) -> Void
    ) {
        for (index, player) in players.enumerated() {
            action(player, UInt8(index + 1))
        }
    }

    func targetID(
        for role: Role,
        in players: [Player]
    ) -> UInt8? {
        guard let index = players.firstIndex(
            where: { $0.role == role }
        ) else { return nil }

        return UInt8(index + 1)
    }
}
