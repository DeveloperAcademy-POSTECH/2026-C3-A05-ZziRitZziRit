//
//  PoliceArrestResultView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct PoliceArrestResultView: View {
    let result: PoliceArrest
    
    var body: some View {
        MafiaLogoView{
            VStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width:56,height:56)
                    .accessibilityHidden(true)
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
    PoliceArrestResultView(result: .success)
}
