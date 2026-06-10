//
//  GameStartView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct GameStartView: View {
    var body: some View {
        MafiaLogoView {
                Text("마피아 게임을 시작합니다")
                    .font(.system(size:30))
                    .multilineTextAlignment(.center)
        }
        .task {
            await HapticPattern.startGame.play()
        }
    }
}

#Preview {
    GameStartView()
}
