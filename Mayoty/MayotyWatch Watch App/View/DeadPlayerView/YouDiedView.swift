//
//  YouDiedView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/5/26.
//


import SwiftUI

struct YouDiedView: View {
    var body: some View {
        MafiaLogoView {
            ZStack {
                
                LinearGradient(
                    colors: [.bgMafia, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    
                    Image("skeleton")
                        .frame(width: 86, height: 111)
                        .accessibilityHidden(true)
                    Text("사망하셨습니다")
                        .font(.headline.bold())
                        .padding(.bottom, 1)
                    Text("⚠️ 게임이 끝날때까지\n발언이 금지됩니다")
                        .font(.footnote.bold())
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                    
                }
                .padding(.top, 40)
                .ignoresSafeArea()
            }
        }
        .task {
            try? await HapticPattern.dead.play()
        }
    }
}

#Preview {
    NavigationStack {
        YouDiedView()
    }
}

