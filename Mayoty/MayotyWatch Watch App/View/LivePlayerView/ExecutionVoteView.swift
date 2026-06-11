//
//  ExecutionVoteView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ExecutionVoteView: View {
    let viewModel: WatchViewModel

    @State private var kill: Bool? = nil

    var body: some View {
        MafiaLogoView {
            VStack(spacing: 25) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 80, height: 80)

                HStack {
                    Button {
                        kill = false
                        viewModel.submitExecutionVote(isAgree: false)

                        Task {
                            try? await HapticPattern.choosePlayer.play()
                        }
                    } label: {
                        Text("살리기")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .foregroundStyle(kill == false ? .btGreen : .gray)

                    Button {
                        kill = true
                        viewModel.submitExecutionVote(isAgree: true)

                        Task {
                            try? await HapticPattern.choosePlayer.play()
                        }
                    } label: {
                        Text("죽이기")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .foregroundStyle(kill == true ? .btRed : .gray)
                }
            }
        }
    }
}
