    //
    //  DeadTest.swift
    //  MayotyWatch Watch App
    //
    //  Created by 이경민 on 6/2/26.
    //

import SwiftUI

struct DeadTest: View {
    var body: some View {
        VStack() {
            HStack {
                Image("MaifaLogo")
                    .resizable(capInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .frame(width: 40, height: 40)
                    //                    .aspectRatio(contentMode: .fit)
                Spacer()
            }
            Image("skeleton")
//                .frame(width: 20, height: 20)
                .resizable()
                .scaledToFit()
            Text("사망하셨습니다")
                .font(.headline)
            Button("Dead") {
                let device = WKInterfaceDevice.current()
                
                Task{
                    for _ in 0..<3 {
                        device.play(.stop)
                        try? await Task.sleep(for: .milliseconds(1000))
                    }
                }
                .task {
                    await HapticCatalog.dead.play()
                }
//            }
        }
        .safeAreaPadding(.top, 0)
    }
}

#Preview {
    DeadTest()
}
