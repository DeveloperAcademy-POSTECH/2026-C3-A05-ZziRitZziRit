//
//  PolNightView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/5/26.
//

import SwiftUI

struct PolNightView: View {
    
    @State private var selectedPlayerID: UUID? = nil
    
    @State private var players: [Player] = [
        Player(color: PlayerColor.pink),
        Player(color: PlayerColor.purple),
        Player(color: PlayerColor.yellow),
        Player(color: PlayerColor.orange),
        Player(color: PlayerColor.mint)
    ]
    
    
    @State private var downloadAmount : Double = 100
    private var progressColor : Color {
        if downloadAmount > 50 {
            return .purple1
        } else if downloadAmount <= 50 && downloadAmount > 20 {
            return .purple2
        } else if downloadAmount <= 20 {
            return .purple3
        }
        return .purple
    }
    
    var body: some View {
        MafiaLogoView {
            VStack{
                Text("조사 할 사람을 지목하세요")
                    .font(Font.system(size: 22))
                    .fontWeight(.bold)
                VStack {
                    ProgressView(value: downloadAmount, total: 100)
                        .frame(width: 200)
                        .padding(1)
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: progressColor)
                        )
                    ScrollView{
                        VStack{
                            ForEach(players) { player in
                                if player.id == selectedPlayerID {
                                    MainButtonView(player: player)
                                } else {
                                    SubButtonView(player: player)
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration:0.15)) {
                                                selectedPlayerID = player.id
                                            }
                                        }
                                        .task {
                                            await HapticPattern.choosePlayer.play()
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(.top, 50)
            .ignoresSafeArea()
        }
    }
}


#Preview {
    NavigationView{
        PolNightView()
    }
}
