//
//  ConnectionFail.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct ConnectionFailView: View {
    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size:40))
                Text("연결 실패")
                    .font(.system(size:30))
                Button(action:{
                    print("")
                }) {
                    Text("다시 시도")
                        .foregroundStyle(.white)
                }
                .foregroundStyle(.btMain)
            }
        }
    }
}

#Preview {
    ConnectionFailView()
}
