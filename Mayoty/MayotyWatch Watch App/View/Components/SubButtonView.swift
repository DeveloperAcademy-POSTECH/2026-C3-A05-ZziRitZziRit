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
                Text("\(player.color?.displayName ?? "") 플레이어")
                    .font(.headline.bold())
            }
            .padding(.leading, 10)
        }
        // 고정 폭은 40-41mm 화면(162-176pt)에서 넘침 — 화면 상대 폭 사용
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.4))
        )
    }
}

#Preview {
    SubButtonView(player: Player())
}
