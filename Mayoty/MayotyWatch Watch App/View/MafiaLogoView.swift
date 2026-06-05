//
//  MafiaTitle.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/2/26.
//

import SwiftUI

struct MafiaLogoView<Content:View>: View {
    let content: Content
    let baseColor: Color
    
    init(baseColor:Color = .bgMain, @ViewBuilder content: () -> Content) {
        self.baseColor = baseColor
        self.content = content()
    }
    
    
    var body: some View {
        ZStack{
            LinearGradient(
<<<<<<< HEAD
                colors: [.bgMain, .black],
=======
                colors:[baseColor, .black],
>>>>>>> a7c4c82 ([merge/#37] pull develop)
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            content
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image("MaifaLogo")
                    .resizable()
                    .frame(width: 60, height: 25)
                    .offset(y: -10)
            }
        }
    }
}
    #Preview {
        NavigationStack {
            MafiaLogoView {
                EmptyView()
            }
        }
    }

