//
//  DayTime.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct DayTime: View {
    var body: some View {
        MafiaLogoView {
            Image(systemName: "sun.max") // 해 lottie asset 받은 후 넣을 예정
                .resizable()
                .foregroundStyle(.yellow)
                .scaledToFit()
        }
    }
}

#Preview {
    DayTime()
}
