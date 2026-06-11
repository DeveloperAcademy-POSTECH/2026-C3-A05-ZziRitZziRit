//
//  DeadPlayerFlowView.swift
//  MayotyWatch Watch App
//
//  Created by Claude on 6/11/26.
//

import SwiftUI

/// 사망자 전용 플로우 — 사망 안내를 잠시 보여준 뒤 진실 확인 화면으로 전환
struct DeadPlayerFlowView: View {
    let players: [Player]

    @State private var showsRoleCheck = false

    var body: some View {
        if showsRoleCheck {
            CheckRoleButtonView(players: players)
        } else {
            YouDiedView()
                .task {
                    try? await Task.sleep(for: .seconds(5))
                    guard !Task.isCancelled else { return }

                    withAnimation {
                        showsRoleCheck = true
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        DeadPlayerFlowView(players: [
            Player(color: .pink, role: .mafia),
            Player(color: .purple, role: .citizen)
        ])
    }
}
