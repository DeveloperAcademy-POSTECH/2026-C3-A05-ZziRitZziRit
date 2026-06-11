//
//  PoliceArrestResultView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct PoliceArrestResultView: View {
    let result: PoliceArrest

    /// 수사 대상 — 누구를 수사한 결과인지 표시
    var target: Player?

    var body: some View {
        MafiaLogoView{
            VStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundStyle(target?.color?.uiColor ?? .white)
                    .accessibilityHidden(true)

                if let color = target?.color {
                    Text("\(color.displayName) 플레이어")
                        .font(.headline)
                        .foregroundStyle(color.uiColor)
                }

                Text("검거 \(result.resultText)")
                    .foregroundStyle(result.resultColor)
                    .font(.title2.bold())
            }
        }
        .task {
            try? await result.resultHaptic.play()
        }
    }
}

#Preview {
    PoliceArrestResultView(
        result: .success,
        target: Player(color: .pink)
    )
}
