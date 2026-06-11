    //
    //  RoleNightView.swift
    //  MayotyWatch Watch App
    //
    //  Created by Namkoong
    //  fix by 이경민 on 6/11/26.
    //

import SwiftUI

struct RoleNightView: View {
    let role: Role
    let viewModel: WatchViewModel
    
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
    
    private func runCountdown() async {
        while downloadAmount > 0 {
            try? await Task.sleep(for: .milliseconds(100))
            if Task.isCancelled { return }
            
            withAnimation(.linear(duration: 0.1)) {
                downloadAmount -= 1
            }
            
            let value = Int(downloadAmount)
            if value <= 50, value > 0, value % 10 == 0 {
                try? await HapticPattern.timeRemaining.play()
            }
        }
    }
    
    private var progressColor : Color {
        if downloadAmount > 50 {
            return .purple1
        } else if downloadAmount > 20 {
            return .purple2
        } else {
            return .purple3
        }
    }
    
    private func sendAnswer(
        playerID: UInt8
    ) {
        switch role {

        case .mafia:
            viewModel.selectMafiaTarget(
                playerID: playerID
            )

        case .police:
            viewModel.selectPoliceTarget(
                playerID: playerID
            )

        case .doctor:
            viewModel.selectDoctorTarget(
                playerID: playerID
            )

        case .citizen:
            viewModel.submitVote(
                targetID: playerID
            )
        }
    }
    
    var body: some View {
        MafiaLogoView {
            VStack{
                    Text(role.selectingText)
                        .font(Font.system(size: 20))
                        .fontWeight(.bold)
                
                VStack {
                        ProgressView(value: downloadAmount, total: 100)
                            .frame(width: 160)
                            .padding(.horizontal, 10)
                            .progressViewStyle(
                                LinearProgressViewStyle(tint: progressColor)
                            )
                    
                    ScrollView{
                        VStack{
                            ForEach(
                                Array(players.enumerated()),
                                id: \.element.id
                            ) { index, player in

                                let playerNumber = UInt8(index + 1)
                                if player.id == selectedPlayerID {
                                    let longPress = LongPressGesture(minimumDuration: 1.5)
                                        .updating($isPressing) { current, state, _ in
                                            state = current
                                        }
                                        .onEnded { success in
                                            if success {
                                                confirmedPlayerID = player.id

                                                sendAnswer(
                                                    playerID: playerNumber
                                                )
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
                                    .onChange(of: isPressing) { _, newValue in
                                        if newValue {
                                            withAnimation(.linear(duration: 1.5)) {
                                                pressProgress = 1
                                            }
                                        } else {
                                            if confirmedPlayerID != player.id {
                                                pressProgress = 0
                                            }
                                        }
                                    }
                                    .simultaneousGesture(longPress)
                                    .onChange(of: confirmedPlayerID) { _, newValue in
                                        if newValue == player.id {
                                            pressProgress = 0
                                        }
                                    }
                                } else {
                                    SubButtonView(player: player)
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration:0.15)) {
                                                selectedPlayerID = player.id
                                                confirmedPlayerID = nil
                                                pressProgress = 0
                                            }
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
        .task {
            await runCountdown()
        }
    }
}


#Preview {
    let sampleViewModel = WatchViewModel()
    return NavigationStack {
        RoleNightView(
            role: .mafia,
            viewModel: sampleViewModel
        )
    }
}
