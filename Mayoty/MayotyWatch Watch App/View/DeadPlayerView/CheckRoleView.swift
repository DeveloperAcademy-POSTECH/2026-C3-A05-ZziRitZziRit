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
                
                Text("진실을 확인합니다")
                    .font(Font.system(size: 27))
                    .fontWeight(.bold)
                    .padding(.top, -15)
                    .padding(.bottom, -2)
                
                ScrollView{
                    VStack(spacing:50) {
                        ForEach(players) { player in
                            RoleCardView(player: player)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    Color.clear
                        .frame(height: 40)
                }
                .ignoresSafeArea()
            }
            .padding(.top, 1)
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
