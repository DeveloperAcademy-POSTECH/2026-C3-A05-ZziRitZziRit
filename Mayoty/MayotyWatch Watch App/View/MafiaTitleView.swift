//
//  MafiaTitle.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/2/26.
//

import SwiftUI

struct MafiaTitleView: View {
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image("마피아 로고 1")
                        .resizable(capInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .frame(width: 40, height: 40)
                        //                    .aspectRatio(contentMode: .fit)
                    Spacer()
                }
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    MafiaTitleView()
}
