//
//  MainButtonView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/5/26.
//

import SwiftUI

struct MainButtonView: View {
    let player: Player
    var isConfirmed: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(player.color?.uiColor ?? .gray)
            
            VStack(alignment: .leading){
                Text("\(player.color?.displayName ?? "") 플레이어")
                    .font(Font.system(size: 23))
                    .fontWeight(.semibold)
                if !isConfirmed {
                    Text("꾹 눌러 확정하기")
                        .font(Font.system(size: 15))
                        .foregroundStyle(Color.textPush)
                }
            }
            .padding(.leading, 10)
        }
        .frame(width: 180, height: 75)
        .background(
            RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(player.color?.uiColor ?? .gray, lineWidth: 3)
        )
    }
}

#Preview {
    NavigationStack{
        RoleNightView(role: .mafia)
    }
}

