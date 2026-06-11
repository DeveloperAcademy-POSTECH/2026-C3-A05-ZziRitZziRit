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
                    .font(.headline.bold())
                if !isConfirmed {
                    Text("꾹 눌러 확정하기")
                        .font(.footnote)
                        .foregroundStyle(Color.textPush)
                }
            }
            .padding(.leading, 10)
        }
        // 고정 폭은 40-41mm 화면(162-176pt)에서 넘침 — 화면 상대 폭 사용
        .frame(maxWidth: .infinity, minHeight: 75)
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
        MainButtonView(player: Player())
    }
}

