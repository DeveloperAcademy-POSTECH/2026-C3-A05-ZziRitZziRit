//
//  RoleAssigning.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct RoleAssigningView: View {
    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                ProgressView{}
                    .frame(width: 30, height: 30)
                Text("직업 배정중")
                    .font(.system(size:30))
            }
        }
        .task {
            await HapticPattern.circularProgress.play()
        }
    }
}

#Preview {
    RoleAssigningView()
}
