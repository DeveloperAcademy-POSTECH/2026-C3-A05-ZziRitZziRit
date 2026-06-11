//
//  ConnectionFailView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ConnectionFailView: View {
    let onRetry: () -> Void

    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size:40))
                    .accessibilityHidden(true)
                Text("연결 실패")
                    .font(.title2)
                Button(action: onRetry) {
                    Text("다시 시도")
                        .foregroundStyle(.white)
                }
                .foregroundStyle(.btMain)
            }
        }
        .task {
            try? await HapticPattern.connectionFail.play()
        }
    }
}

#Preview {
    ConnectionFailView {}
}
