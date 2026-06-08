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

    var body: some View {
        ListView(
            leadingTitle: "플레이어",
            trailingTitle: "\(players.count)/5",
            items: players
        ) {
            StateView(
                state: "ExecutionVoteState",
                remainingTime: remainingTime
            )
        } cell: { player in
            ListCell {
                HStack(spacing: 30) {
                    Text(player.color?.rawValue ?? "색상 없음")

                    Text(player.isAlive ? "생존" : "사망")

                    if player === finalDefender {
                        Text("최후 변론자")
                    }

                    Spacer()
                }
            }
        }
    }
}

