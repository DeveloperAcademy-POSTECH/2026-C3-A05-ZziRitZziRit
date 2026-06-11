//
//  WaitView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/5/26.
import SwiftUI

struct WaitView: View {
    var body: some View {
        MafiaLogoView {
            Text("잠시후,\n다른 플레이어들의\n지목 화면이\n표시됩니다")
                .multilineTextAlignment(.center)
                .font(.headline.bold())
                .padding(.bottom, 20)
        }
    }
}

#Preview {
    NavigationView(){
        WaitView()
    }
}
