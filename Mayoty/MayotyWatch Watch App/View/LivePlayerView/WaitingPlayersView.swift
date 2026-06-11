//
//  WaitingPlayersView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct WaitingPlayersView: View {
    let count: Int

    var body: some View {
        MafiaLogoView {
            VStack(spacing: 20) {
                Text("플레이어 접속중")
                    .font(.title3)
                ProgressView()
                    .frame(width: 30, height: 30)
                Text("\(count)/\(GameRule.requiredPlayerCount)")
                    .font(.title3)
            }
        }
        .task {
            try? await HapticPattern.circularProgress.play()
        }
    }
}

#Preview {
    WaitingPlayersView(count: 3)
}
