//
//  ConfettiAnimationView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/10/26.
//

import SwiftUI

struct ConfettiAnimationView<Content:View>: View {
    private let totalFrames = 169
    private let frameInterval = 0.04

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate: Date?

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            if reduceMotion {
                frameImage(1)
            } else {
                // TimelineView는 뷰가 사라지면 자동으로 멈춤 —
                // 재귀 asyncAfter처럼 뷰 소멸 후에도 도는 일이 없음
                TimelineView(.periodic(from: .now, by: frameInterval)) { context in
                    frameImage(frame(at: context.date))
                }
            }

            content
        }
        .onAppear {
            startDate = Date()
        }
    }

    private func frame(at date: Date) -> Int {
        guard let startDate else { return 1 }

        let elapsed = max(0, date.timeIntervalSince(startDate))
        return Int(elapsed / frameInterval) % totalFrames + 1
    }

    private func frameImage(_ frame: Int) -> some View {
        Image(String(format: "confetti_%03d", frame))
            .resizable()
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

#Preview {
    ConfettiAnimationView{
        EmptyView()
    }
}
