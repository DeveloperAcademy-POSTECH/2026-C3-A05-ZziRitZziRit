//
//  DayTimeView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct DayTimeView: View {
    let viewModel: WatchViewModel

    var body: some View {
        MafiaLogoView {
            SunAnimationView()
        }
        .onAppear {
            viewModel.autoNext(after: 2.0)
        }
    }
}
