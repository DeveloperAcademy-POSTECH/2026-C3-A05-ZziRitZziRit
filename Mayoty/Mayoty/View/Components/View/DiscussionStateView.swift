//
//  DiscussionStateView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//

import SwiftUI

struct DiscussionStateView: View {
    let players: [Player]
    let title: String
    let remainingTime: Int

    var body: some View {
        ListView(
            leadingTitle: "플레이어",
            trailingTitle: "\(players.count)/5",
            items: players
        ) {
            StateView(
                state: title,
                remainingTime: remainingTime
            )
        } cell: { player in
            ListCell {
                HStack {
                    Text(player.color?.rawValue ?? "-")
                        .frame(width: 70, alignment: .leading)
                    Text(player.isAlive ? "생존" : "사망")
                        .frame(width: 40, alignment: .leading)
                    Text(player.role?.displayName ?? "역할 없음")
                    Spacer()
                }
            }
        }
    }
}

