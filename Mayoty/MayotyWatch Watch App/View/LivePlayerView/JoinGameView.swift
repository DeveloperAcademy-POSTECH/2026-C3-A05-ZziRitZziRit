//
//  JoinGameView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/10/26.
//

import SwiftUI

struct JoinGameView: View {
    let viewModel: WatchViewModel

    var body: some View {
        MafiaLogoView {
            VStack {
                MafiaStackView()
                    .frame(width: 120, height: 130)

                Button {
                    Task { try? await HapticPattern.choosePlayer.play() }
                } label: {
                    Text("참가하기")
                        .foregroundStyle(.white)
                }
                .foregroundStyle(.btMain)
                .frame(width: 140, height: 70)
            }
        }
    }
}
