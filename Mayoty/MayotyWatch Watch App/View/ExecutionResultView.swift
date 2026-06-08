//
//  PlayerLiveorDieByVote.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ExecutionResultView: View {
    let excutionResult: ExecutionResult
    
    var body: some View {
        MafiaLogoView {
            VStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
//                    .foregroundStyle(.white) //최다 지목된 플레이어 색깔
                Text(excutionResult.textResult)
                    .foregroundStyle(excutionResult.textColor)
                    .font(.title)
            }
        }
    }
}

#Preview {
    ExecutionResultView(excutionResult: .survive)
}
