//
//  VoteManager.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

import Foundation

enum VoteResult {
    case noVotes
    case tie
    case singleTop(Player)
}

final class VoteManager {
    private var targetVotes: [UUID: UUID] = [:]
    private var executionVotes: [UUID: Bool] = [:]

    // MARK: - 일반 투표

    func submitVote(voter: Player, target: Player) {
        guard voter.isAlive, target.isAlive else { return }
        guard voter.id != target.id else { return }
        targetVotes[voter.id] = target.id
    }

    /// 생존자 전원이 투표를 마쳤는지 — 조기 종료 판정용
    func hasAllVotes(from players: [Player]) -> Bool {
        let aliveCount = players.filter(\.isAlive).count
        return aliveCount > 0 && targetVotes.count >= aliveCount
    }

    // MARK: - 일반 투표 결과

    func getVoteResult(from players: [Player]) -> VoteResult {
        let voteCounts = Dictionary(
            grouping: targetVotes.values,
            by: { $0 }
        )
        .mapValues { $0.count }

        guard !voteCounts.isEmpty else {
            return .noVotes
        }

        guard let maxCount = voteCounts.values.max() else {
            return .noVotes
        }

        let topPlayerIds = voteCounts
            .filter { $0.value == maxCount }
            .map { $0.key }

        guard topPlayerIds.count == 1,
              let topPlayerId = topPlayerIds.first,
              let topPlayer = players.first(where: { $0.id == topPlayerId })
        else {
            return .tie
        }

        return .singleTop(topPlayer)
    }

    // MARK: - 찬반 투표

    func submitExecutionVote(
        voter: Player,
        finalDefensePlayer: Player,
        isAgree: Bool
    ) {
        guard voter.isAlive else { return }
        guard voter.id != finalDefensePlayer.id else { return }
        executionVotes[voter.id] = isAgree
    }

    /// 변론자를 제외한 생존자 전원이 찬반 투표를 마쳤는지 — 조기 종료 판정용
    func hasAllExecutionVotes(
        from players: [Player],
        excluding finalDefensePlayer: Player
    ) -> Bool {
        let voterCount = players
            .filter { $0.isAlive && $0.id != finalDefensePlayer.id }
            .count

        return voterCount > 0 && executionVotes.count >= voterCount
    }

    // MARK: - 찬반 투표 결과

    var shouldBeExecuted: Bool {
        let agreeCount = executionVotes.values.filter { $0 }.count
        let totalCount = executionVotes.values.count

        return 2 * agreeCount > totalCount
    }

    func resetTargetVotes() {
        targetVotes.removeAll()
    }

    func resetExecutionVotes() {
        executionVotes.removeAll()
    }
}
