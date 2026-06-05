//
//  RoleResult.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI


struct RoleResult: View {
    let role: Role
    var body: some View {
        MafiaLogoView {
            VStack(spacing: 5) {
                Text("당신의 직업은")
                    .font(.system(size:30))
                Image(systemName: role.iconName)
                    .font(.system(size:60))
                Text(role.displayName)
                    .font(.system(size:30))
            }
        }
    }
}

#Preview {
    RoleResult(role: .doctor)
}
