//
//  PlayerLiveorDieByVote.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ExecutionResultView: View {
    let excutionResult: ExecutionResult

    /// 처형 대상 — 누구의 결과인지 표시
    var defendant: Player?

    var body: some View {
        MafiaLogoView {
            VStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(defendant?.color?.uiColor ?? .white)
                    .accessibilityHidden(true)

                if let color = defendant?.color {
                    Text("\(color.displayName) 플레이어")
                        .font(.headline)
                        .foregroundStyle(color.uiColor)
                }

                Text(excutionResult.textResult)
                    .foregroundStyle(excutionResult.textColor)
                    .font(.title)
            }
        }
    }
}

#Preview {
    ExecutionResultView(
        excutionResult: .survive,
        defendant: Player(color: .pink)
    )
}
