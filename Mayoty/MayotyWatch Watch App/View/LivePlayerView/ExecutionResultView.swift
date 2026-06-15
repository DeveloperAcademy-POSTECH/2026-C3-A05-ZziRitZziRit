//
//  PlayerLiveorDieByVote.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ExecutionResultView: View {
    let excutionResult: ExecutionResult
    let viewModel: WatchViewModel

    var body: some View {
        MafiaLogoView {
            VStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 80, height: 80)

                Text(excutionResult.textResult)
                    .foregroundStyle(excutionResult.textColor)
                    .font(.title)
            }
        }
        .onAppear {
            viewModel.autoNext(after: 2.0)
        }
    }
}
