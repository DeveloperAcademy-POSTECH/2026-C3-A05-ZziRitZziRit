//
//  CheckJobView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/8/26.
//

import SwiftUI

struct CheckRoleView: View {
    @Environment(\.dismiss) private var dismiss
    
    
    // TODO: 게임 상태(Store/ViewModel)에서 플레이어 목록 주입받도록 변경
    @State private var players: [Player] = [
        Player(color: PlayerColor.pink, role: Role.mafia),
        Player(color: PlayerColor.purple, role: Role.citizen),
        Player(color: PlayerColor.yellow, role: Role.citizen),
        Player(color: PlayerColor.orange, role: Role.doctor),
        Player(color: PlayerColor.mint, role: Role.police)
    ]
    
    
    
    var body: some View {
        MafiaLogoView {
            VStack{
                
                ScrollView{
                    VStack(spacing: 10) {
                        ForEach(players) { player in
                            RoleCardView(player: player)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .padding(.top, 50)
                .ignoresSafeArea()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        CheckRoleView()
    }
}
