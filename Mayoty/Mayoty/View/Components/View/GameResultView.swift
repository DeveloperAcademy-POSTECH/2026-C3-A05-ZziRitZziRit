//
//  GameResultView.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import SwiftUI

struct GameResultView: View {
    let winner: Team

    var body: some View {
        VStack(spacing: 24) {
            Text("게임 종료")
                .font(.largeTitle)
                .bold()

            Text(winner.displayName)
                .font(.title)
        }
    }
}
