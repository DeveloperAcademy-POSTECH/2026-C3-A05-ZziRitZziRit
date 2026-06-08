//
//  WelcomeMafia.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct WelcomeMafia: View {
    var body: some View {
        MafiaLogoView{
                Text("마피아 세계에 \n오신걸 \n환영합니다.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 30))
        }
    }
}

#Preview {
        WelcomeMafia()
}
