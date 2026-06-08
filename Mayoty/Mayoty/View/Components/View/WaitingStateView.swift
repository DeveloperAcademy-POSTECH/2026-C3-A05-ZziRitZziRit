//
//  WaitingStateView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//

import SwiftUI

struct WaitingStateView: View {
    let players: [Player]
    let remainingTime: Int

    var body: some View {
        ListView(
            leadingTitle: "연결된 플레이어",
            trailingTitle: "\(players.count)/5",
            items: players
        ) {
            StateView(
                state: "WaitingState",
                remainingTime: remainingTime
            )
        } cell: { player in
            ListCell {
                HStack {
                    Text("Player \(String(player.id.uuidString.prefix(4)))")
                    Spacer()
                }
            }
        }
    }
}

