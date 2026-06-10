//
//  ExecutionVoteView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ExecutionVoteView: View {
    @State private var model: WatchViewModel?
    @State private var kill: Bool = false
    
    var body: some View {
        MafiaLogoView{
            VStack(spacing: 25) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
//                    .foregroundStyle(.white) //최다 지목된 플레이어 색깔
                HStack {
                    Button {
                        kill = false
                    } label: {
                        Text("살리기")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .foregroundStyle(kill ? .gray : .btGreen)
                    .task {
                        try? await HapticPattern.choosePlayer.play()
                        print("살리기")
                    }
                    
                    Button {
                        kill = true
                    } label: {
                        Text("죽이기")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .foregroundStyle(kill ? .btRed : .gray)
                    .task {
                        try? await HapticPattern.choosePlayer.play()
                        print("죽이기")
                    }
                }
            }
        }
    }
}

#Preview {
    ExecutionVoteView()
}
