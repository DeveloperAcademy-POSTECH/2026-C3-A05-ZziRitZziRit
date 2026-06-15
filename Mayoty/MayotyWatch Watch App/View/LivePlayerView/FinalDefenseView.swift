//
//  FinalDefenseView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct FinalDefenseView: View {
    let viewModel: WatchViewModel

    var body: some View {
        MafiaLogoView {
            VStack {
                ProgressView()
                    .frame(width: 30, height: 30)

                Text("최후 변론중")
                    .font(.system(size: 25))
            }
        }
        .onAppear {
            Task {
                try? await HapticPattern.circularProgress.play()
            }

            viewModel.autoNext(after: 2.0)
        }
    }
}
