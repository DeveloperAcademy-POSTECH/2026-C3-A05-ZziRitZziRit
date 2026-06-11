//
//  FinalDefenseView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct FinalDefenseView: View {
    /// 변론 대상 (nil이면 정보 미수신 — 일반 문구)
    var defendant: Player?
    var isMe: Bool = false

    var body: some View {
        MafiaLogoView{
            VStack(spacing: 8) {
                if isMe {
                    Image(systemName: "person.wave.2.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(defendant?.color?.uiColor ?? .white)
                        .accessibilityHidden(true)
                    Text("당신의 최후 변론\n시간입니다")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                } else {
                    ProgressView{}
                        .frame(width: 30, height: 30)

                    if let color = defendant?.color {
                        Text("\(color.displayName) 플레이어\n최후 변론중")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(color.uiColor)
                    } else {
                        Text("최후 변론중")
                            .font(.title3)
                    }
                }
            }
            .task {
                try? await HapticPattern.circularProgress.play()
            }
        }
    }
}

#Preview {
    FinalDefenseView(defendant: Player(color: .pink), isMe: false)
}
