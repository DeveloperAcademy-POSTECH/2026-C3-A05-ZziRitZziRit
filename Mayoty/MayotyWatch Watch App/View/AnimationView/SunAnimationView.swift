//
//  SunAnimationView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/10/26.
//

import SwiftUI

struct SunAnimationView: View {
    private let totalFrames = 347
    @State private var currentFrame = 1
    @State private var cachedImages: [UIImage] = []

    var body: some View {
        Group {
            if cachedImages.isEmpty {
                Color.clear
            } else {
                Image(uiImage: cachedImages[currentFrame - 1])
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            preloadImages()
        }
    }

    private func preloadImages() {
        DispatchQueue.global(qos: .userInitiated).async {
            var images: [UIImage] = []
            for i in 1...totalFrames {
                let name = String(format: "sun_%03d", i)
                if let img = UIImage(named: name) {
                    images.append(img)
                }
            }
            DispatchQueue.main.async {
                cachedImages = images
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.015) {
            currentFrame = (currentFrame % totalFrames) + 1
            startAnimation()
        }
    }
}

#Preview {
    SunAnimationView()
}
