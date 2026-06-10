//
//  VictoryView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/11/26.
//

import SwiftUI

struct VictoryView: View {
    let victory: Victory
    
    var body: some View {
        MafiaLogoView(baseColor: victory.backGroundColor) {
            victory.animation {
                VStack {
                    Text(victory.text)
                        .foregroundStyle(victory.textColor)
                        .font(.title)
                    Button{
                            // TODO: go to 1st step
                    } label: {
                        Text("처음으로")
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(.btMain)
                }
            }
        }
        .task {
            try? await victory.haptic.play()
        }
    }
}

#Preview {
    VictoryView(victory: .mafia)
}
