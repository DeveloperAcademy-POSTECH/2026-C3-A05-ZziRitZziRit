//
//  CheckRoleButtonView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/8/26.
//

import SwiftUI

struct CheckRoleButtonView: View {
    var body: some View {
        MafiaLogoView {
            VStack(spacing: -30){
                
                Text("플레이어들의\n직업을\n확인해보세요")
                    .multilineTextAlignment(.center)
                    .font(Font.system(size: 30).bold())
                    .frame(maxWidth: 300, maxHeight: 200)
                
                NavigationLink{
                    CheckRoleView()
                } label: {
                    Text("확인하기")
                        .foregroundStyle(.white)
                        .font(Font.system(size: 25).bold())
                }
                .tint(.btMain)
                .buttonStyle(.glass)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack{
        CheckRoleButtonView()
    }
}
