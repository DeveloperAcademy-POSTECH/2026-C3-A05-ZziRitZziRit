//
//  CitizenVictory.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct CitizenVictory: View {
    var body: some View {
        MafiaLogoView(baseColor: .bgCitizen) {
            VStack {
                Text("시민 승리")
                    .foregroundStyle(.green)
                    .font(.title)
                Button(action:{
                    print("")
                }) {
                    Text("처음으로")
                        .foregroundStyle(.white)
                }
                .foregroundStyle(.btMain)
            }
        }
    }
}

#Preview {
    CitizenVictory()
}
