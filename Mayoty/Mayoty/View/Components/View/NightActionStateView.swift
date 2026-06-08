//
//  NightActionStateView.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import SwiftUI

struct NightActionStateView: View {
    let players: [Player]
    let title: String
    let remainingTime: Int
    let selectedPlayer: Player?
    let onSelect: (Player) -> Void

    var body: some View {
        ListView(
            leadingTitle: "연결된 기기",
            trailingTitle: "\(players.count)/5",
            items: players
        ) {
            StateView(
                state: title,
                remainingTime: remainingTime
            )
        } cell: { player in
            ListCell {
                HStack(spacing: 30) {
                    Text(player.color?.rawValue ?? "색상 없음")

                    Text(player.isAlive ? "생존" : "사망")

                    Spacer()

                    Button {
                        onSelect(player)
                    } label: {
                        Image(systemName: player === selectedPlayer ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.title)
                    }
                    .disabled(!player.isAlive)
                }
            }
        }
    }
}

