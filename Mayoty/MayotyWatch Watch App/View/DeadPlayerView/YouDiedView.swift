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
                    Text("사망하셨습니다")
                        .font(Font.system(size: 22))
                        .fontWeight(.bold)
                        .padding(.bottom, 1)
                    Text("⚠️ 게임이 끝날때까지\n발언이 금지됩니다")
                        .font(Font.system(size: 13))
                        .fontWeight(.semibold)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                    
                }
                .padding(.top, 40)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    NavigationStack {
        YouDiedView()
    }
}

