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
                colors:[baseColor, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            content
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image("MafiaLogo")
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

