//
//  StateView.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import SwiftUI

struct StateView: View {
    let state: String
    let remainingTime: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(state)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)
            Text("남은 시간: \(remainingTime)초")
                .font(.title2)
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StateView(state: "currentState", remainingTime: 0)
}
