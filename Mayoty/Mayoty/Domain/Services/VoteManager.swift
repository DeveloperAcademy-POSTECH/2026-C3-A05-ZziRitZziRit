//
//  VoteManager.swift
//  Mayoty
//
//  Created by sun on 6/3/26.
//

import Foundation

final class VoteManager {
    private var targetVotes: [UUID: UUID] = [:]
    private var executionVotes: [UUID: Bool] = [:]
    
    // MARK: - 일반 투표

    func submitVote(voter: Player, target: Player) {
        guard voter.id != target.id else { return }
        targetVotes[voter.id] = target.id
    }
    
    // MARK: - 최다 득표자 찾기

    func getSingleTopVotedPlayer(from players: [Player]) -> Player? {
        let voteCounts = Dictionary(
            grouping: targetVotes.values,
            by: { $0 }
        )
        .mapValues { $0.count }

        let maxCount = voteCounts.values.max()

        let topPlayerIds = voteCounts
            .filter { $0.value == maxCount }
            .map { $0.key }

        guard topPlayerIds.count == 1,
              let topPlayerId = topPlayerIds.first
        else {
            return nil
        }

        return players.first { $0.id == topPlayerId }
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

    // MARK: - 찬반 투표 집계

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
