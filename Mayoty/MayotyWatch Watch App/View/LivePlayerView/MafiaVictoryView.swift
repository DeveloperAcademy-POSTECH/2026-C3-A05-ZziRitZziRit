//
//  MafiaVictoryView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct MafiaVictoryView: View {
    var body: some View {
        MafiaLogoView {
            BloodAnimationView {
                VStack {
                    Text("마피아 승리")
                        .foregroundStyle(.red)
                        .font(.title)
                    Button {
                        Task { await HapticPattern.choosePlayer.play() }
                    } label: {
                        Text("처음으로")
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(.btMain)
                }
            }
        }
        .task {
            await HapticPattern.mafiaWin.play()
        }
    }
}

#Preview {
    MafiaVictoryView()
}
