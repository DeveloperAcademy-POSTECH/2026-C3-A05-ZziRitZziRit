//
//  KillorNot.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ExecutionVoteView: View {
    @State private var model: WatchViewModel?
    @State private var manager: WatchCentralManager?
    @State private var kill: Bool = false
    
    var body: some View {
        MafiaLogoView{
            VStack(spacing: 25) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
//                    .foregroundStyle(.white) //최다 지목된 플레이어 색깔
                HStack{
                    Button(action: {
                        manager?.sendSaveOrKill(.save)
                        kill = false
                    }) {
                        Text("살리기")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .foregroundStyle(kill ? .gray : .btGreen)
                    
                    Button(action: {
                        manager?.sendSaveOrKill(.kill)
                        kill = true
                    }) {
                        Text("죽이기")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .foregroundStyle(kill ? .btRed : .gray)
                }
            }
        }
    }
}

#Preview {
    ExecutionVoteView()
}
