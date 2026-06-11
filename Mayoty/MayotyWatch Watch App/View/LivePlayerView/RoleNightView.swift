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

    /// 낮 투표 화면 여부 (문구·자기 투표 차단이 달라짐)
    var isVote: Bool = false

    @State private var selectedPlayerID: UUID? = nil
    @GestureState private var isPressing = false
    @State private var pressProgress: Double = 0
    @State private var confirmedPlayerID: UUID? = nil

    /// iPhone이 playerColor 명령으로 보내준 실제 명단 —
    /// 전송하는 playerID(index+1)가 호스트의 배정 순서와 일치해야 함
    private var players: [Player] {
        viewModel.commandStore.players
    }

    private var promptText: String {
        isVote ? "처형할 사람에게 투표하세요" : role.selectingText
    }

    /// 죽은 플레이어와 (투표에서는) 자기 자신은 선택 불가 — iPhone도 거부함
    private func isSelectable(index: Int, player: Player) -> Bool {
        guard player.isAlive else { return false }

        if isVote, index + 1 == viewModel.commandStore.myPlayerNumber {
            return false
        }

        return true
    }

    private func disabledLabel(index: Int) -> String {
        index + 1 == viewModel.commandStore.myPlayerNumber ? "나" : "사망"
    }

    @State private var downloadAmount : Double = 100

    private func runCountdown() async {
        // iPhone이 보내준 페이즈 제한 시간에 진행 바를 동기화
        let totalSeconds = max(5, viewModel.commandStore.phaseSeconds)
        let tick = Double(totalSeconds) / 100.0

        while downloadAmount > 0 {
            try? await Task.sleep(for: .seconds(tick))
            if Task.isCancelled { return }

            withAnimation(.linear(duration: tick)) {
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
                    Text(promptText)
                        .font(.headline.bold())
                
                VStack {
                        ProgressView(value: downloadAmount, total: 100)
                            .frame(maxWidth: 160)
                            .padding(.horizontal, 10)
                            .progressViewStyle(.linear)
                            .tint(progressColor)
                    
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
                                } else if isSelectable(index: index, player: player) {
                                    SubButtonView(player: player)
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration:0.15)) {
                                                selectedPlayerID = player.id
                                                confirmedPlayerID = nil
                                                pressProgress = 0
                                            }
                                        }
                                } else {
                                    // 죽은 플레이어/자기 자신 — 선택 불가 표시
                                    SubButtonView(player: player)
                                        .opacity(0.35)
                                        .overlay(alignment: .trailing) {
                                            Text(disabledLabel(index: index))
                                                .font(.footnote.bold())
                                                .foregroundStyle(
                                                    disabledLabel(index: index) == "사망"
                                                        ? .red
                                                        : .secondary
                                                )
                                                .padding(.trailing, 12)
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
