//
//  ConfettiAnimationView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/10/26.
//

import SwiftUI

struct ConfettiAnimationView<Content:View>: View {
    private let totalFrames = 169
    @State private var currentFrame = 1
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Image(String(format: "confetti_%03d", currentFrame))
                .resizable()
                .onAppear {
                    startAnimation()
                }
                .ignoresSafeArea()
            
            content
        }
    }
    
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {  // 40ms
            currentFrame = (currentFrame % totalFrames) + 1
                startAnimation()
                // 한 번만 재생하고 멈춤
        }
    }
}

#Preview {
    ConfettiAnimationView{
        EmptyView()
    }
}
