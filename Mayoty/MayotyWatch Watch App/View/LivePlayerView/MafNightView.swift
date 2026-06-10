//
//  MafNightView.swift
//  Mayoty
//
//  Created by JaewhanNamkoong on 6/5/26.
//

import SwiftUI


struct MafNightView: View {
    
    @State private var selectedPlayerID: UUID? = nil
    @GestureState private var isPressing = false
    @State private var pressProgress: Double = 0
    @State private var confirmedPlayerID: UUID? = nil
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
                Text("죽일 사람을 지목하세요")
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
                                    let longPress = LongPressGesture(minimumDuration: 3)
                                        .updating($isPressing) { current, state, _ in
                                            state = current
                                        }
                                        .onEnded { success in
                                            if success {
                                                confirmedPlayerID = player.id
                                            }
                                        }

                                    ZStack {
                                        MainButtonView(player: player, isConfirmed: confirmedPlayerID == player.id)
                                            .overlay(
                                                Group {
                                                    if confirmedPlayerID == player.id {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.system(size: 28))
                                                            .foregroundStyle(.green)
                                                            .offset(x: 70, y: -28)
                                                            .transition(.scale)
                                                    }
                                                }
                                            )

                                        GeometryReader { geo in
                                            let w = geo.size.width
                                            let h = geo.size.height
                                            ZStack(alignment: .leading) {
                                                Rectangle().fill(Color.clear)
                                                Rectangle()
                                                    .fill(Color.black.opacity(0.35))
                                                    .frame(width: (confirmedPlayerID == player.id) ? 0 : w * pressProgress, height: h)
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .allowsHitTesting(false)
                                    }
                                    .onChange(of: isPressing) { oldValue, newValue in
                                        if newValue {
                                            withAnimation(.linear(duration: 3)) {
                                                pressProgress = 1
                                            }
                                        } else {
                                            if confirmedPlayerID != player.id {
                                                pressProgress = 0
                                            }
                                        }
                                    }
                                    .simultaneousGesture(longPress)
                                    .onChange(of: confirmedPlayerID) { oldValue, newValue in
                                        if newValue == player.id {
                                            pressProgress = 0
                                        }
                                    }
                                } else {
                                    SubButtonView(player: player)
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.15)) {
                                                selectedPlayerID = player.id
                                                // cancel previous confirmation and progress
                                                confirmedPlayerID = nil
                                                pressProgress = 0
                                            }
                                        }
<<<<<<< HEAD:Mayoty/MayotyWatch Watch App/View/LivePlayerView/MafNightView.swift
                                        .task {
                                            await HapticPattern.choosePlayer.play()
                                        }
                                    
=======
>>>>>>> origin/develop:Mayoty/MayotyWatch Watch App/View/MafNightView.swift
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
    NavigationStack {
        MafNightView()
    }
}

