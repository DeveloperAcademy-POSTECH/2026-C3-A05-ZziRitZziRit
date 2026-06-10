//
//  ConnectionWaitingView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ConnectionWaitingView: View {
    var body: some View {
        MafiaLogoView{
            VStack {
                ProgressView{}
                    .frame(width: 30, height: 30)
                Text("연결 대기중")
                    .font(.system(size:25))
                
            }
            .task {
                try? await HapticPattern.circularProgress.play()
            }
        }
    }
}

#Preview {
    ConnectionWaitingView()
}
