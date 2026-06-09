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
        guard voter.id != target.id else { return }
        targetVotes[voter.id] = target.id
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
        guard voter.id != finalDefensePlayer.id else { return }
        executionVotes[voter.id] = isAgree
    }

    // MARK: - 시간 초과 처리

    func submitDefaultExecutionVote(
        voter: Player,
        finalDefensePlayer: Player
    ) {
        submitExecutionVote(
            voter: voter,
            finalDefensePlayer: finalDefensePlayer,
            isAgree: false
        )
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
