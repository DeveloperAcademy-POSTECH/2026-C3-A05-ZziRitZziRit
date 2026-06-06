//
//  MainButtonView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/5/26.
//

import SwiftUI

extension PlayerColor {
    var uiColor: Color {
        switch self {
        case .pink:   return .hmPink
        case .purple: return .hmViolet
        case .yellow: return .hmYellow
        case .mint:   return .hmMint
        case .orange: return .hmOrange
        }
    }

    var displayName: String {
        switch self {
        case .pink:   return "핑크색"
        case .purple: return "보라색"
        case .yellow: return "노란색"
        case .mint:   return "민트색"
        case .orange: return "주황색"
        }
    }
}
struct MainButtonView: View {
    let player: Player
    
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
                Text("꾹 눌러 확정하기")
                    .font(Font.system(size: 15))
                    .foregroundStyle(Color.textPush)
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
        MafNightView()
    }
}


