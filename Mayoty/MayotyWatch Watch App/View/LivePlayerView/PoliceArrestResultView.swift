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
//                    .foregroundStyle(.playerColor) //지목한 사람의 색깔 들어오기 -> 지목 CardView 완성 후
                    .resizable()
                    .frame(width:56,height:56)
                Text("검거 \(result.resultText)")
                    .foregroundStyle(result.resultColor)
                    .font(.system(size:35))
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
