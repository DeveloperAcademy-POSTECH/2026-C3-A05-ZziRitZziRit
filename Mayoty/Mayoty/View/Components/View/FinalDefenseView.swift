//
//  FinalDefenseView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//

import SwiftUI

struct FinalDefenseView: View {
    let players: [Player]
    let finalDefender: Player?
    let remainingTime: Int
    let stateTitle: String

    var body: some View {
        ListView(
            leadingTitle: "플레이어",
            trailingTitle: "\(players.count)/5",
            items: players
        ) {
            StateView(
                state: stateTitle,
                remainingTime: remainingTime
            )
        } cell: { player in
            ListCell {
                HStack(spacing: 30) {
                    Text(player.color?.rawValue ?? "색상 없음")

                    Text(player.isAlive ? "생존" : "사망")

                    Spacer()

                    if player === finalDefender {
                        Text("최후 변론자")
                    }
                }
            }
        }
    }
}

