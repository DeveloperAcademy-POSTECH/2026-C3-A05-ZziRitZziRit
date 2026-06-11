//
//  SunAnimationView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/10/26.
//

import SwiftUI

struct SunAnimationView: View {
    private let totalFrames = 347

    /// 347장 풀스크린 프레임을 UIImage 배열로 프리로드하면
    /// watchOS 메모리 한도를 위협하므로 에셋 카탈로그 캐시에 맡김.
    /// 33ms(~30fps)면 워치 디스플레이에 충분.
    private let frameInterval = 1.0 / 30.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate: Date?

    var body: some View {
        Group {
            if reduceMotion {
                frameImage(1)
            } else {
                TimelineView(.periodic(from: .now, by: frameInterval)) { context in
                    frameImage(frame(at: context.date))
                }
            }
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
        Image(String(format: "sun_%03d", frame))
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

#Preview {
    SunAnimationView()
}
