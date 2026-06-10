//
//  WaitingPlayersView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct WaitingPlayersView: View {
    var body: some View {
        MafiaLogoView {
            VStack(spacing: 20) {
                Text("플레이어 접속중")
                    .font(.system(size:25))
                ProgressView()
                    .frame(width: 30, height: 30)
                Text("n/5")
                    .font(.system(size:25))
            }
        }
        .task {
            try? await HapticPattern.circularProgress.play()
        }
    }
}

#Preview {
    WaitingPlayersView()
}
