//
//  BLEViewModel.swift
//  Mayoty
//
//  Created by sun on 6/7/26.
//

import Foundation
import Observation

@Observable
final class BLEViewModel {

    var isAdvertising: Bool = false
    var bluetoothStateText: String = "Unknown"
    var connectedWatchIDs: [UUID] = []

    /// 연결 순서 기준의 플레이어 목록 — Watch 연결/해제 시에만 갱신
    var connectedPlayers: [Player] = []

    var answers: [UUID: BLEAnswer] = [:]
    var logs: [String] = []

    var game: MafiaGame

    private let peripheralManager: iPhoneBLEPeripheralManager
    private let watchCommandManager: WatchCommandManager
    private var eventTask: Task<Void, Never>?

    init(
        game: MafiaGame,
        peripheralManager: iPhoneBLEPeripheralManager,
        watchCommandManager: WatchCommandManager
    ) {
        self.game = game
        self.peripheralManager = peripheralManager
        self.watchCommandManager = watchCommandManager

        observePeripheralEvents()
    }

    deinit {
        eventTask?.cancel()
    }

    // MARK: - 광고 제어

    func startAdvertising() {
        peripheralManager.startAdvertising()
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }

    // MARK: - 이벤트 관찰

    private func observePeripheralEvents() {
        eventTask = Task { [weak self] in
            guard let self else { return }

            for await event in self.peripheralManager.events {
                await MainActor.run {
                    self.handle(event)
                }
            }
        }
    }

    // MARK: - 이벤트 처리

    private func handle(_ event: BLEPeripheralEvent) {
        switch event {
        case let .bluetoothStateChanged(stateText, log):
            bluetoothStateText = stateText

            if let log {
                addLog(log)
            }

        case let .advertisingChanged(isAdvertising, log):
            self.isAdvertising = isAdvertising
            addLog(log)

        case let .watchConnected(id):
            watchConnected(id)

        case let .watchDisconnected(id):
            watchDisconnected(id)

        case let .answerReceived(id, answer):
            receiveAnswer(from: id, answer: answer)

        case let .log(text):
            addLog(text)
        }
    }

    // MARK: - Watch 연결/해제

    private func watchConnected(_ id: UUID) {
        let isNew = !connectedWatchIDs.contains(id)

        // 정원(5명) 초과 신규 워치는 거절 — 광고가 항시 유지되므로 6번째도
        // 구독은 가능하지만, 등록하면 로비 시작 조건(정확히 5명)이 영구히 깨짐
        if isNew,
           player(for: id) == nil,
           connectedWatchIDs.count >= GameRule.requiredPlayerCount {
            addLog("Watch rejected (slot full): \(id.uuidString.prefix(8))")
            watchCommandManager.send(.connectionFailed(), to: id)
            return
        }

        insertWatch(id)

        guard isNew else { return }

        addLog("Watch connected: \(id.uuidString.prefix(8))")

        watchCommandManager.sendConnectionSucceeded(to: id)

        if game.currentState is WaitingState {
            watchCommandManager.sendWaitingPlayers(
                count: connectedWatchIDs.count
            )
        } else {
            // 게임 진행 중 재연결 — 현재 페이즈 화면을 복원
            resyncWatch(id)
        }
    }

    private func watchDisconnected(_ id: UUID) {
        connectedWatchIDs.removeAll { $0 == id }
        connectedPlayers.removeAll { $0.watchUUID == id }

        addLog("Watch disconnected: \(id.uuidString.prefix(8))")

        if game.currentState is WaitingState {
            watchCommandManager.sendWaitingPlayers(
                count: connectedWatchIDs.count
            )
        }
    }

    /// 게임 진행 중 재연결된 Watch에 현재 페이즈 명령을 재전송
    private func resyncWatch(_ id: UUID) {
        guard
            let player = player(for: id),
            let index = game.players.firstIndex(where: { $0.id == player.id })
        else { return }

        let playerNumber = UInt8(index + 1)
        let state = game.currentState

        // 사망자는 어느 페이즈든 사망자 플로우로 복원 (결과 화면 제외)
        if !player.isAlive {
            if state is ResultState, let winner = game.winner {
                watchCommandManager.send(.gameEnded(winner: winner), to: player)
            } else {
                watchCommandManager.sendDeadFlow(to: player, players: game.players)
            }

            addLog("Watch resynced (dead): \(id.uuidString.prefix(8))")
            return
        }

        // 밤 선택 화면은 전체 색상 명단과 사망 상태가 있어야 그릴 수 있음
        watchCommandManager.sendPlayerColors(
            to: game.players,
            watch: player
        )

        if let role = player.role {
            // 자기 번호/역할 복원 (워치 자기 식별용)
            watchCommandManager.send(
                .roleResult(targetID: playerNumber, role: role),
                to: player
            )
        }

        for (index, rosterPlayer) in game.players.enumerated() where !rosterPlayer.isAlive {
            watchCommandManager.send(
                .playerDied(targetID: UInt8(index + 1)),
                to: player
            )
        }

        let remaining = game.timerManager.remainingTime
        let defendantID = game.finalDefensePlayer.map {
            watchCommandManager.number(of: $0, in: game.players)
        } ?? 0

        switch state {
        case is RoleAssigningState:
            watchCommandManager.send(.roleAssigning(), to: player)

            if let role = player.role {
                watchCommandManager.send(
                    .roleResult(targetID: playerNumber, role: role),
                    to: player
                )
            }

        case is IntroductionState, is DiscussionState:
            watchCommandManager.send(.dayTime(), to: player)

        case is MafiaState:
            sendNightTurn(.mafia, kind: .mafiaTurn, player: player, number: playerNumber, seconds: remaining)

        case is PoliceState:
            sendNightTurn(.police, kind: .policeTurn, player: player, number: playerNumber, seconds: remaining)

        case is DoctorState:
            sendNightTurn(.doctor, kind: .doctorTurn, player: player, number: playerNumber, seconds: remaining)

        case is NightState:
            watchCommandManager.send(
                .nightWaiting(targetID: playerNumber, activeRole: .mafia),
                to: player
            )

        case is VoteState:
            watchCommandManager.send(
                .vote(seconds: UInt8(clamping: remaining)),
                to: player
            )

        case is FinalDefenseState:
            watchCommandManager.send(
                .finalDefense(
                    defendantID: defendantID,
                    seconds: UInt8(clamping: remaining)
                ),
                to: player
            )

        case is ExecutionVoteState:
            watchCommandManager.send(
                .executionVote(
                    defendantID: defendantID,
                    seconds: UInt8(clamping: remaining)
                ),
                to: player
            )

        case is ExecutionResultState:
            watchCommandManager.send(
                .executionResult(
                    defendantID: defendantID,
                    didExecute: game.voteManager.shouldBeExecuted
                ),
                to: player
            )

        case is ResultState:
            if let winner = game.winner {
                watchCommandManager.send(.gameEnded(winner: winner), to: player)
            }

        default:
            break
        }

        addLog("Watch resynced: \(id.uuidString.prefix(8))")
    }

    private func sendNightTurn(
        _ activeRole: Role,
        kind: BLECommandKind,
        player: Player,
        number: UInt8,
        seconds: Int
    ) {
        if player.role == activeRole {
            watchCommandManager.send(
                BLECommand(
                    kind: kind,
                    targetID: number,
                    value: UInt8(clamping: seconds)
                ),
                to: player
            )
        } else {
            watchCommandManager.send(
                .nightWaiting(targetID: number, activeRole: activeRole),
                to: player
            )
        }
    }

    // MARK: - 응답 수신

    func receiveAnswer(from id: UUID, answer: BLEAnswer) {
        watchConnected(id)
        answers[id] = answer

        addLog(
            "\(id.uuidString.prefix(8)) → \(answer.kind), value: \(answer.value)"
        )

        handleGameAnswer(from: id, answer: answer)
    }

    // MARK: - 게임 액션 변환

    private func handleGameAnswer(from id: UUID, answer: BLEAnswer) {
        switch answer.kind {
        case .join:
            break

        case .mafiaSelected:
            guard let sender = player(for: id),
                  sender.role == .mafia,
                  sender.isAlive,
                  let target = player(for: answer.value),
                  target.isAlive
            else {
                addLog("mafiaSelected rejected: \(id.uuidString.prefix(8))")
                return
            }

            game.handleAction(.mafiaSelected(target: target))

        case .policeSelected:
            guard let sender = player(for: id),
                  sender.role == .police,
                  sender.isAlive,
                  let target = player(for: answer.value),
                  target.isAlive
            else {
                addLog("policeSelected rejected: \(id.uuidString.prefix(8))")
                return
            }

            game.handleAction(.policeSelected(target: target))

        case .doctorSelected:
            guard let sender = player(for: id),
                  sender.role == .doctor,
                  sender.isAlive,
                  let target = player(for: answer.value),
                  target.isAlive
            else {
                addLog("doctorSelected rejected: \(id.uuidString.prefix(8))")
                return
            }

            game.handleAction(.doctorSelected(target: target))

        case .voteSubmitted:
            guard let voter = player(for: id),
                  voter.isAlive,
                  let target = player(for: answer.value)
            else { return }

            game.handleAction(
                .voteSubmitted(
                    voter: voter,
                    target: target
                )
            )

        case .executionVoteSubmitted:
            guard let voter = player(for: id),
                  voter.isAlive
            else { return }

            game.handleAction(
                .executionVoteSubmitted(
                    voter: voter,
                    isAgree: answer.value == 1
                )
            )
        }
    }

    // MARK: - 플레이어 찾기

    private func player(for number: UInt8) -> Player? {
        let index = Int(number) - 1

        guard game.players.indices.contains(index) else {
            addLog("Invalid player number: \(number)")
            return nil
        }

        return game.players[index]
    }

    private func player(for watchID: UUID) -> Player? {
        game.players.first { player in
            player.watchId == watchID.uuidString
        }
    }

    // MARK: - 로그

    private func addLog(_ text: String) {
        logs.insert(text, at: 0)
    }

    // MARK: - Watch 등록

    private func insertWatch(_ id: UUID) {
        guard !connectedWatchIDs.contains(id) else { return }

        connectedWatchIDs.append(id)
        connectedPlayers.append(
            Player(
                id: id,
                watchId: id.uuidString
            )
        )
    }
}
