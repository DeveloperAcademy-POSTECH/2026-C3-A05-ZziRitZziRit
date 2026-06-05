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
                .clipped()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image("마피아 로고 1")
                    .resizable()
                    .frame(width: 47, height: 47)
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

