    //
    //  MafiaTitle.swift
    //  MayotyWatch Watch App
    //
    //  Created by 이경민 on 6/2/26.
    //

import SwiftUI

struct MafiaLogoView<Content:View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack{
            LinearGradient(
                colors:[.bgMain, .black],
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

