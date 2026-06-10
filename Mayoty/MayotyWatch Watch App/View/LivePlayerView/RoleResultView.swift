//
//  RoleResult.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI


struct RoleResultView: View {
    let role: Role
    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                Text("당신의 직업은")
                    .font(.system(size:30))
                Image(role.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text(role.displayName)
                    .font(.system(size:30))
            }
        }
        .task {
            try? await HapticPattern.revealRole.play()
        }
    }
}

#Preview {
    RoleResultView(role: .police)
}
