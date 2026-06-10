//
//  RoleAssignView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//

import SwiftUI

struct RoleAssignView: View {
    let players: [Player]
    let remainingTime: Int

    var body: some View {
        ListView(
            leadingTitle: "연결된 기기",
            trailingTitle: "\(players.count)/5",
            items: players
        ) {
            StateView(state: "RoleAssignState", remainingTime: remainingTime)
        } cell: { player in
            ListCell {
                HStack {
                    Text("Player \(player.id.uuidString.prefix(4))")
                        .frame(width: 100,alignment: .leading )

                    Text(player.color?.rawValue ?? "색상 없음")
                        .frame(width: 70, alignment: .leading)
                    
                    Spacer()
                    
                    Text(player.role?.displayName ?? "역할 없음")
                    
                    
                }
            }
        }
    }
}



