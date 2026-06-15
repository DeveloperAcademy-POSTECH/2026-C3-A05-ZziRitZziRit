//
//  WatchBLETestView.swift
//  Mayoty
//
//  Created by sun on 6/12/26.
//

import SwiftUI

struct WatchBLETestView: View {
    @State private var viewModel = WatchViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(viewModel.connectionState.stateDescription)
                    .font(.caption)
                    .multilineTextAlignment(.center)

                Button("Scan") {
                    viewModel.scan()
                }

                Divider()

                Button("마피아 → 1번 지목") {
                    viewModel.selectMafiaTarget(playerID: 1)
                }

                Button("경찰 → 2번 지목") {
                    viewModel.selectPoliceTarget(playerID: 2)
                }

                Button("의사 → 3번 지목") {
                    viewModel.selectDoctorTarget(playerID: 3)
                }

                Divider()

                Button("낮 투표 → 4번") {
                    viewModel.submitVote(targetID: 4)
                }

                Button("최종 투표 → 찬성") {
                    viewModel.submitExecutionVote(isAgree: true)
                }

                Button("최종 투표 → 반대") {
                    viewModel.submitExecutionVote(isAgree: false)
                }
            }
            .padding()
        }
    }
}
