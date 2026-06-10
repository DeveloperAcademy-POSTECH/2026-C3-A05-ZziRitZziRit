//
//  MafiaStackView.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/10/26.
//

import SwiftUI

struct MafiaStackView: View {
    var body: some View {
        ZStack {
            Image("MafiaLogoPerson")
                .resizable()
                .frame(width: 110, height: 110)
            Image("MafiaLogo")
                .resizable()
                .frame(width: 100, height: 35)
                .offset(y:55)
        }
    }
}

#Preview {
    MafiaStackView()
}
