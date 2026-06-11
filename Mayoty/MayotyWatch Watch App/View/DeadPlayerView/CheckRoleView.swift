//
//  CheckJobView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/8/26.
//

import SwiftUI

struct CheckRoleView: View {
    @Environment(\.dismiss) private var dismiss

    /// BLE playerRole 명령으로 수신한 실제 직업 명단 (사망자에게만 공개됨)
    let players: [Player]

    var body: some View {
        MafiaLogoView {
            VStack{

                Text("진실을 확인합니다")
                    .font(.title3.bold())
                    .padding(.top, -15)
                    .padding(.bottom, -2)
                
                ScrollView{
                    VStack(spacing: 12) {
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
            .task {
                // 뷰가 먼저 사라지면 sleep이 취소되어 stale dismiss가 호출되지 않음
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { return }
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack{
        CheckRoleView(players: [
            Player(color: .pink, role: .mafia),
            Player(color: .purple, role: .citizen),
            Player(color: .yellow, role: .citizen),
            Player(color: .orange, role: .doctor),
            Player(color: .mint, role: .police)
        ])
    }
}
