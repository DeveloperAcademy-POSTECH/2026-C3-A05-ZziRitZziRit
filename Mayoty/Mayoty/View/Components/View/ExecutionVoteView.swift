//
//  ExecutionVoteView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//

import SwiftUI

struct ExecutionVoteView: View {
    let players: [Player]
    let finalDefender: Player?
    let remainingTime: Int
    let onSubmitExecutionVote: (Player, Bool) -> Void

    @State private var selectedVoter: Player?
    @State private var votes: [(voter: Player, isAgree: Bool)] = []

    private var alivePlayers: [Player] {
        players.filter { $0.isAlive }
    }

    var body: some View {
        VStack(spacing: 12) {
            ListView(
                leadingTitle: "처형 투표",
                trailingTitle: "\(votes.count)/\(alivePlayers.count)",
                items: alivePlayers
            ) {
                StateView(
                    state: "ExecutionVoteState",
                    remainingTime: remainingTime
                )
            } cell: { player in
                ListCell {
                    HStack {
                        Text(player.color?.rawValue ?? "색상 없음")

                        if player === finalDefender {
                            Text("최후 변론자")
                        }

                        Spacer()

                        if let voteResult = voteResult(of: player) {
                            Text(voteResult ? "찬성" : "반대")
                        } else {
                            Button("투표자 선택") {
                                selectedVoter = player
                            }
                            .disabled(hasVoted(player))
                        }
                    }
                }
            }

            if let voter = selectedVoter {
                HStack {
                    Text("\(voter.color?.rawValue ?? "색상 없음") 투표")

                    Button("찬성") {
                        submitVote(voter: voter, isAgree: true)
                    }

                    Button("반대") {
                        submitVote(voter: voter, isAgree: false)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
        }
    }

    private func submitVote(voter: Player, isAgree: Bool) {
        votes.append((voter: voter, isAgree: isAgree))
        onSubmitExecutionVote(voter, isAgree)
        selectedVoter = nil
    }

    private func voteResult(of voter: Player) -> Bool? {
        votes.first { $0.voter === voter }?.isAgree
    }

    private func hasVoted(_ player: Player) -> Bool {
        votes.contains { $0.voter === player }
    }
}
