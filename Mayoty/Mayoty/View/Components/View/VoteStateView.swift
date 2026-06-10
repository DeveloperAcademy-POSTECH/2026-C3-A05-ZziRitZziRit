//
//  VoteStateView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//

import SwiftUI

struct VoteStateView: View {
    let players: [Player]
    let remainingTime: Int
    let onSubmitVote: (Player, Player) -> Void

    @State private var selectedVoter: Player?
    @State private var votes: [(voter: Player, target: Player)] = []

    private var alivePlayers: [Player] {
        players.filter { $0.isAlive }
    }

    var body: some View {
        VStack(spacing: 12) {
            ListView(
                leadingTitle: selectedVoter == nil ? "투표자 선택" : "투표 대상 선택",
                trailingTitle: "\(votes.count)/\(alivePlayers.count)",
                items: alivePlayers
            ) {
                StateView(state: "VoteState", remainingTime: remainingTime)
            } cell: { player in
                ListCell {
                    HStack {
                        Text(player.color?.rawValue ?? "-")
                            .frame(width: 70, alignment: .leading)
                        Text(player.isAlive ? "생존" : "사망")
                            .frame(width: 40, alignment: .leading)
                        Text(player.role?.displayName ?? "역할 없음")

                        Spacer()

                        if let votedTarget = votedTarget(of: player) {
                            Text("→ \(votedTarget.color?.rawValue ?? "색상 없음")")
                        } else {
                            Button(buttonTitle(for: player)) {
                                handleTap(player)
                            }
                            .disabled(isDisabled(player))
                        }
                    }
                }
            }
        }
    }

    private func handleTap(_ player: Player) {
        if let voter = selectedVoter {
            votes.append((voter: voter, target: player))
            onSubmitVote(voter, player)
            selectedVoter = nil
        } else {
            selectedVoter = player
        }
    }

    private func votedTarget(of voter: Player) -> Player? {
        votes.first { $0.voter === voter }?.target
    }

    private func hasVoted(_ player: Player) -> Bool {
        votes.contains { $0.voter === player }
    }

    private func buttonTitle(for player: Player) -> String {
        if selectedVoter == nil {
            return "투표자"
        } else {
            return "선택"
        }
    }

    private func isDisabled(_ player: Player) -> Bool {
        if hasVoted(player) {
            return true
        }

        if let selectedVoter {
            return player === selectedVoter
        }

        return false
    }
}
