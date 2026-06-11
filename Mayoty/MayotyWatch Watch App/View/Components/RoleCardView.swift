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
        // GeometryReader는 제안받은 공간 전체로 확장돼 셀 높이가 어긋남 — 상대 폭 프레임 사용
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(player.color?.uiColor ?? .yellow)
                .accessibilityHidden(true)

            VStack(alignment: .leading){
                Text("\(player.color?.displayName ?? "") 플레이어")
                    .font(.footnote.bold())
                Text("\(player.role?.displayName ?? "")")
                    .font(.headline.bold())
                    .foregroundStyle(roleTint)
            }
            .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
        .padding(.horizontal, 8)
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
        role: .mafia
    )
    return RoleCardView(player: sample)
}
