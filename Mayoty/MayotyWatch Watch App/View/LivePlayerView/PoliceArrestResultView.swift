//
//  PoliceArrestResultView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct PoliceArrestResultView: View {
    let result: PoliceArrest
    let viewModel: WatchViewModel
    
    var body: some View {
        MafiaLogoView {
            VStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 56, height: 56)

                Text("검거 \(result.resultText)")
                    .foregroundStyle(result.resultColor)
                    .font(.system(size: 35))
            }
        }
        .onAppear {
            Task {
                try? await result.resultHaptic.play()
            }

            viewModel.autoNext(after: 2.0)
        }
    }
}
