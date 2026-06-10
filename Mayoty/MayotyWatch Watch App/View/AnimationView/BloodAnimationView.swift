//
//  BloodAnimationView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/10/26.
//

import SwiftUI

struct BloodAnimationView<Content:View>: View {
    private let totalFrames = 75
    private let frameInterval: UInt64 = 70_000_000 // 0.07s
    let content: Content

    @State private var currentFrame = 1

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Image(String(format: "blood_%03d", currentFrame))
                .resizable()
                .task {
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: frameInterval)
                        currentFrame = currentFrame % totalFrames + 1
                    }
                }
                .ignoresSafeArea()
            
            content
        }
    }
}
#Preview {
    BloodAnimationView {
        EmptyView()
    }
}
