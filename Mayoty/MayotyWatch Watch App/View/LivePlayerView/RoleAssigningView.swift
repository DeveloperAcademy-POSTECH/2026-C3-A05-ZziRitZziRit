//
//  RoleAssigningView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct RoleAssigningView: View {
    let viewModel: WatchViewModel

    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                ProgressView()
                    .frame(width: 30, height: 30)

                Text("직업 배정중")
                    .font(.system(size: 30))
            }
        }
        .onAppear {
            Task {
                try? await HapticPattern.circularProgress.play()
            }

            viewModel.autoNext(after: 1.5)
        }
    }
}
