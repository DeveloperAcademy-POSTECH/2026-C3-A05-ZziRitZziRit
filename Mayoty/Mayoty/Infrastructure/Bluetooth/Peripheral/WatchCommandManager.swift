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

    func number(of player: Player, in players: [Player]) -> UInt8 {
        guard let index = players.firstIndex(where: { $0.id == player.id }) else {
            return 0
        }
        return UInt8(index + 1)
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
        sendDeadList(to: players)

        forEachPlayer(players) { player, _ in
            if player.isAlive {
                send(.dayTime(), to: player)
            } else {
                sendDeadFlow(to: player, players: players)
            }
        }
    }

    /// 사망 상태 동기화 — 생존자 워치 명단에서 사망자를 표시/비활성하기 위함
    func sendDeadList(to players: [Player]) {
        let deadNumbers = players.enumerated()
            .filter { !$0.element.isAlive }
            .map { UInt8($0.offset + 1) }

        guard !deadNumbers.isEmpty else { return }

        forEachAlivePlayer(players) { player in
            for number in deadNumbers {
                send(.playerDied(targetID: number), to: player)
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

    func sendMafiaTurn(to players: [Player], seconds: Int = GameTime.mafia) {
        sendRoleTurn(
            to: players,
            activeRole: .mafia,
            activeKind: .mafiaTurn,
            seconds: seconds
        )
    }

    func sendPoliceTurn(to players: [Player], seconds: Int = GameTime.police) {
        sendRoleTurn(
            to: players,
            activeRole: .police,
            activeKind: .policeTurn,
            seconds: seconds
        )
    }

    func sendDoctorTurn(to players: [Player], seconds: Int = GameTime.doctor) {
        sendRoleTurn(
            to: players,
            activeRole: .doctor,
            activeKind: .doctorTurn,
            seconds: seconds
        )
    }

    /// 수사 결과 — targetID에 수사 대상 번호를 실어 워치가 대상 색상을 표시
    func sendPoliceResult(
        target: Player,
        isMafia: Bool,
        in players: [Player]
    ) {
        guard let (police, _) = playerWithID(
            for: .police,
            in: players
        ) else { return }

        send(
            .policeResult(
                targetID: number(of: target, in: players),
                isMafia: isMafia
            ),
            to: police
        )
    }

    func sendVote(to players: [Player], seconds: Int = GameTime.vote) {
        sendDeadList(to: players)

        forEachAlivePlayer(players) { player in
            send(.vote(seconds: UInt8(clamping: seconds)), to: player)
        }
    }

    func sendFinalDefense(
        defendant: Player,
        to players: [Player],
        seconds: Int = GameTime.finalDefense
    ) {
        let defendantID = number(of: defendant, in: players)

        forEachAlivePlayer(players) { player in
            send(
                .finalDefense(
                    defendantID: defendantID,
                    seconds: UInt8(clamping: seconds)
                ),
                to: player
            )
        }
    }

    func sendExecutionVote(
        defendant: Player,
        to players: [Player],
        seconds: Int = GameTime.executionVote
    ) {
        let defendantID = number(of: defendant, in: players)

        forEachAlivePlayer(players) { player in
            send(
                .executionVote(
                    defendantID: defendantID,
                    seconds: UInt8(clamping: seconds)
                ),
                to: player
            )
        }
    }

    /// 처형 결과는 이 시점 생존자(변론자 포함)에게만 — 사망자는 사망자 플로우 유지
    func sendExecutionResult(
        defendant: Player,
        didExecute: Bool,
        to players: [Player]
    ) {
        let defendantID = number(of: defendant, in: players)

        forEachAlivePlayer(players) { player in
            send(
                .executionResult(
                    defendantID: defendantID,
                    didExecute: didExecute
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
        activeKind: BLECommandKind,
        seconds: Int
    ) {
        sendDeadList(to: players)

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
                        targetID: targetID,
                        value: UInt8(clamping: seconds)
                    ),
                    to: player
                )
            } else {
                send(
                    .nightWaiting(
                        targetID: targetID,
                        activeRole: activeRole
                    ),
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
