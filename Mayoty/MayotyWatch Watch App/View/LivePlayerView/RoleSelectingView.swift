//
//  RoleSelectingView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct RoleSelectingView: View {
    let role: Role
    let viewModel: WatchViewModel

    var body: some View {
        MafiaLogoView {
            VStack {
                ProgressView()
                    .frame(width: 30, height: 30)

                Text("\(role.displayName) 지목중")
                    .font(.system(size: 25))
            }
        }
        .onAppear {
            viewModel.autoNext(after: 1.5)
        }
    }
}
