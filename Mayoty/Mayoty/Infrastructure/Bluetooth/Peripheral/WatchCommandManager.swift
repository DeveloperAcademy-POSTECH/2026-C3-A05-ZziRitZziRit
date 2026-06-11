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

    /// 전체 Watch 브로드캐스트
    func send(_ command: BLECommand) {
        peripheralManager.sendCommand(command)
    }

    /// 특정 플레이어의 Watch에만 전송
    /// Watch는 자기 식별자를 모르므로, 개인화 명령은 전송 계층에서 대상을 지정해야 함
    func send(_ command: BLECommand, to player: Player) {
        guard let centralID = player.watchUUID else {
            GameLogger.bluetooth(
                "watchId 없음 — \(command.kind) 전송 불가: \(player.color?.rawValue ?? "unknown")"
            )
            return
        }

        peripheralManager.sendCommand(command, to: centralID)
    }

    func send(_ command: BLECommand, to centralID: UUID) {
        peripheralManager.sendCommand(command, to: centralID)
    }

    func sendConnectionSucceeded(to centralID: UUID) {
        send(.connectionSucceeded(), to: centralID)
    }

    func sendWaitingPlayers(count: Int) {
        send(.waitingPlayers(count: UInt8(clamping: count)))
    }

    /// 게임 참가자에게만 — 거절된(미등록) 구독 워치가 게임 화면으로 끌려가지 않도록
    func sendRoleAssigning(to players: [Player]) {
        for player in players {
            send(.roleAssigning(), to: player)
        }
    }

    func sendRoleResults(to players: [Player]) {
        forEachPlayer(players) { player, targetID in
            guard let role = player.role else { return }

            send(
                .roleResult(
                    targetID: targetID,
                    role: role
                ),
                to: player
            )
        }
    }

    /// 낮 화면 — 생존자에게만. 사망자는 사망자 플로우 유지
    func sendDayTime(to players: [Player]) {
        forEachPlayer(players) { player, _ in
            if player.isAlive {
                send(.dayTime(), to: player)
            } else {
                sendDeadFlow(to: player, players: players)
            }
        }
    }

    /// 사망자 전용 플로우 진입 명령 + 진실 확인용 전체 직업 공개
    /// 사망자에게만 전송되므로 스포일러 위험 없음
    func sendDeadFlow(to player: Player, players: [Player]) {
        send(.youDied(), to: player)

        for (index, rosterPlayer) in players.enumerated() {
            guard let role = rosterPlayer.role else { continue }

            send(
                .playerRole(
                    targetID: UInt8(index + 1),
                    role: role
                ),
                to: player
            )
        }
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
        guard let (police, targetID) = playerWithID(
            for: .police,
            in: players
        ) else { return }

        send(
            .policeResult(
                targetID: targetID,
                isMafia: isMafia
            ),
            to: police
        )
    }

    func sendVote(to players: [Player]) {
        forEachAlivePlayer(players) { player in
            send(.vote(), to: player)
        }
    }

    func sendFinalDefense(to players: [Player]) {
        forEachAlivePlayer(players) { player in
            send(.finalDefense(), to: player)
        }
    }

    func sendExecutionVote(to players: [Player]) {
        forEachAlivePlayer(players) { player in
            send(.executionVote(), to: player)
        }
    }

    /// 처형 결과는 이 시점 생존자(변론자 포함)에게만 — 사망자는 사망자 플로우 유지
    func sendExecutionResult(didExecute: Bool, to players: [Player]) {
        forEachAlivePlayer(players) { player in
            send(
                BLECommand(
                    kind: .executionResult,
                    value: didExecute ? 1 : 0
                ),
                to: player
            )
        }
    }

    /// 사망자 포함 전 참가자에게 — 단 거절된(미등록) 구독 워치는 제외
    func sendGameEnded(winner: Team, to players: [Player]) {
        for player in players {
            send(.gameEnded(winner: winner), to: player)
        }
    }

    /// 전체 색상 명단은 모든 Watch가 선택 화면에 사용하므로 브로드캐스트
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

    /// 특정 Watch 한 대에만 전체 색상 명단 재전송 (재연결 복구용)
    func sendPlayerColors(to players: [Player], watch player: Player) {
        for (index, rosterPlayer) in players.enumerated() {
            guard let color = rosterPlayer.color else { continue }

            send(
                BLECommand(
                    kind: .playerColor,
                    targetID: UInt8(index + 1),
                    value: color.bleValue
                ),
                to: player
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
            // 사망한 직업자는 턴을 받으면 안 됨 — 사망 판정이 우선
            guard player.isAlive else {
                sendDeadFlow(to: player, players: players)
                return
            }

            if player.role == activeRole {
                send(
                    BLECommand(
                        kind: activeKind,
                        targetID: targetID
                    ),
                    to: player
                )
            } else {
                send(
                    .nightWaiting(targetID: targetID),
                    to: player
                )
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

    func forEachAlivePlayer(
        _ players: [Player],
        action: (Player) -> Void
    ) {
        for player in players where player.isAlive {
            action(player)
        }
    }

    func playerWithID(
        for role: Role,
        in players: [Player]
    ) -> (Player, UInt8)? {
        guard let index = players.firstIndex(
            where: { $0.role == role }
        ) else { return nil }

        return (players[index], UInt8(index + 1))
    }
}

extension Player {
    /// BLE central identifier — Watch 연결 시 central id 문자열로 저장됨
    var watchUUID: UUID? {
        watchId.flatMap(UUID.init(uuidString:))
    }
}
