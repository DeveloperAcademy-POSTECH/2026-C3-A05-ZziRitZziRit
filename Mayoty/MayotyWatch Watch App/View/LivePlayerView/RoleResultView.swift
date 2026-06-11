//
//  RoleResult.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI


struct RoleResultView: View {
    let viewModel: WatchViewModel

    var body: some View {
        let role = viewModel.commandStore.role

        MafiaLogoView {
            VStack(spacing: 5) {
                Text("당신의 직업은")
                    .font(.system(size: 20))

                Image(role.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                Text(role.displayName)
                    .font(.system(size: 20))
            }
        }
        .onAppear {
            Task {
                try? await HapticPattern.revealRole.play()
            }

            viewModel.autoNext(after: 2.0)
        }
    }
}
