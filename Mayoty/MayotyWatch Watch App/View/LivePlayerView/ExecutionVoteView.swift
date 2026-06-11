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

    private var defendant: Player? {
        viewModel.commandStore.defendant
    }

    private var isMeDefendant: Bool {
        viewModel.commandStore.isMeDefendant
    }

    var body: some View {
        MafiaLogoView {
            VStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundStyle(defendant?.color?.uiColor ?? .white)
                    .accessibilityHidden(true)

                if isMeDefendant {
                    // 변론자 본인은 투표 불가 (iPhone도 거부) — 버튼 대신 안내
                    Text("당신에 대한 처형 투표가\n진행 중입니다")
                        .font(.headline.bold())
                        .multilineTextAlignment(.center)
                } else {
                    if let color = defendant?.color {
                        Text("\(color.displayName) 플레이어를\n처형할까요?")
                            .font(.headline.bold())
                            .multilineTextAlignment(.center)
                    }

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
}
