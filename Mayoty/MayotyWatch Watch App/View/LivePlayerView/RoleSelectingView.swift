//
//  RoleSelectingView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct RoleSelectingView: View {
    /// 지금 턴이 진행 중인 직업 (자기 직업이 아님)
    let role: Role

    var body: some View {
        MafiaLogoView{
            VStack {
                ProgressView{}
                    .frame(width: 30, height: 30)
                Text(role.nightActionLabel)
                    .font(.title3)
            }
        }
        .task {
            try? await HapticPattern.circularProgress.play()
        }
    }
}

#Preview {
    RoleSelectingView(role: .doctor)
}
