//
//  ConnectionSucceedView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ConnectionSucceedView: View {
    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size:40))
                    .accessibilityHidden(true)
                Text("연결 완료")
                    .font(.title2)
            }
        }
        .task {
            try? await HapticPattern.connectionSucceed.play()
        }
    }
}

#Preview {
    ConnectionSucceedView()
}
