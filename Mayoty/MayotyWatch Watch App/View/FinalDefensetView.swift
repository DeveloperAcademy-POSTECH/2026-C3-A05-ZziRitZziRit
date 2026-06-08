//
//  FinalStatement.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

struct FinalDefensementView: View {
    var body: some View {
        MafiaLogoView{
            VStack {
                ProgressView{}
                    .frame(width: 30, height: 30)
                Text("최후 변론중")
                    .font(.system(size:25))
                
            }
        }
    }
}

#Preview {
    FinalDefensementView()
}
