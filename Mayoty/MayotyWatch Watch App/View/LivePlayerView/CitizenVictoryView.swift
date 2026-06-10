//
//  CitizenVictoryView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct CitizenVictoryView: View {
    var body: some View {
        MafiaLogoView(baseColor: .bgCitizen) {
            VStack {
                Text("시민 승리")
                    .foregroundStyle(.green)
                    .font(.title)
                    .fontWeight(.bold)
                Button{
                    // TODO: go to 1st step
                } label: {
                    Text("처음으로")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.btMain)
            }
        }
        .task {
            await HapticPattern.citizenWin.play()
        }
    }
}

#Preview {
    CitizenVictoryView()
}
