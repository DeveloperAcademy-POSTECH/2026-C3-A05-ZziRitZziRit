//
//  RoleCardView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/8/26.
//

import SwiftUI

struct RoleCardView: View {
    
    let player: Player
    
    private var roleTint: Color {
        guard let role = player.role else { return .primary }
        switch role {
        case .mafia:
            return .red
        case .police, .doctor, .citizen:
            return .green
        }
    }
    
    var body: some View {
        
        
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(player.color?.uiColor ?? .yellow)
            
            VStack(alignment: .leading){
                Text("\(player.color?.displayName ?? "") 플레이어")
                    .font(Font.system(size: 15))
                    .fontWeight(.semibold)
                Text("\(player.role?.displayName ?? "")")
                    .font(Font.system(size: 23))
                    .foregroundStyle(roleTint)
            }
            .padding(.leading, 10)
        }
        .frame(width: 180, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(player.color?.uiColor ?? .yellow, lineWidth: 3)
        )
    }
}



#Preview {
    let sample = Player(
        id: UUID(),
        color: .pink,
        role: .citizen
    )
    return RoleCardView(player: sample)
}
