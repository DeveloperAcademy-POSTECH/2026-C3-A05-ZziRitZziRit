//
//  SubButtonView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/5/26.
//


import SwiftUI

struct SubButtonView: View {
    
    let player: Player

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(player.color?.uiColor ?? .gray)
            
            VStack(alignment: .leading){
                Text("\(player.color?.displayName ?? "") 플레이어")                    .font(Font.system(size: 20))
                    .fontWeight(.semibold)
            }
            .padding(.leading, 10)
        }
        .frame(width: 170, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.4))
        )
    }
}

#Preview {
    RoleNightView(role: .mafia)
}
