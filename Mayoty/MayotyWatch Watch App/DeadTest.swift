//
//  DeadTest.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/2/26.
//

import SwiftUI

struct DeadTest: View {
    var body: some View {
        MafiaLogoView{
//            ScrollView {
                VStack() {
                    Image("해골이미지2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    Text("사망하셨습니다")
                        .font(.headline)
                    Button("Dead") {
                        let device = WKInterfaceDevice.current()
                        
                        Task{
                            for _ in 0..<3 {
                                device.play(.stop)
                                try? await Task.sleep(for: .milliseconds(1000))
                            }
                            device.play(.start)
                            try? await Task.sleep(for: .milliseconds(600))
                        }
                    }
                }
                .task {
                    await HapticPattern.dead.play()
                }
//            }
        }
        .safeAreaPadding(.top, 0)
    }
}

#Preview {
    DeadTest()
}
