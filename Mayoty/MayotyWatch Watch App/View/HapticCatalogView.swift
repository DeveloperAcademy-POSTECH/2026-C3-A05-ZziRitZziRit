    //
    //  HapticCatalogView.swift
    //  MafiaTest Watch App
    //
    //  Created by 이경민 on 5/25/26.
    //

import SwiftUI

/*
 duration     sleep
 .click               150         250
 .notification        400         500
 .success             500         600
 .failure             600         700
 .start               300         400
 .stop                300         400
 .directionUp/Down    300         400
 .retry               800         900
 */

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension Color {
    
    static let purple1 = Color(hex: "#e0c1fe")
    static let purple2 = Color(hex: "#b770ff")
    static let purple3 = Color(hex: "8e1eff")  // #을 제거하고 사용해도 됩니다.
}

struct HapticCatalogView: View {
    let haptics: [(String, WKHapticType)] = [
        ("Notification", .notification),
        //        ("Direction Up", .directionUp),
        ("Direction Up, Down", .directionDown),
        ("Success", .success),
        //        ("Failure", .failure),
        ("Failure, Retry", .retry),
        ("Start", .start),
        ("Stop", .stop),
        ("Click", .click)
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
        VStack() {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(haptics, id: \.0) { name, type in
                        Button(name) {
                            WKInterfaceDevice.current().play(type)
                        }
                    }
                    
                    Button("Start Game") {
                        Task { await HapticPattern.startGame.play() }
                    }
                    .buttonStyle(.bordered)

                    Button("Reveal Role") {
                        Task { await HapticPattern.revealRole.play() }
                    }

                    Button("Role Time to Action") {
                        Task { await HapticPattern.roleTimeToAction.play() }
                    }

                    Button("Choose Player") {
                        Task { await HapticPattern.choosePlayer.play() }
                    }

                    Button("Confirm Choose Player") {
                        Task { await HapticPattern.confirmChoosPlayer.play() }
                    }

                    VStack {
                        ProgressView("남은 시간", value: downloadAmount, total: 100)
                            .padding()
                            .progressViewStyle(
                                LinearProgressViewStyle(tint: progressColor)
                            )
                    }

                    Button("Time Remaining 5seconds") {
                        Task { await HapticPattern.timeRemaining.play() }
                    }

                    Button("Dead") {
                        Task { await HapticPattern.dead.play() }
                    }

                    Button("시민 승리") {
                        Task { await HapticPattern.citizenWin.play() }
                    }

                    Button("마피아 승리") {
                        Task { await HapticPattern.mafiaWin.play() }
                    }

                    ProgressView()

                    Button("대기중") {
                        Task { await HapticPattern.circularProgress.play() }
                    }

                    Button("연결완료") {
                        Task { await HapticPattern.connectionOk.play() }
                    }

                    Button("연결실패") {
                        Task { await HapticPattern.connectionFail.play() }
                    }

                    Button("경찰이 마피아 찾음") {
                        Task { await HapticPattern.policeFoundMafia.play() }
                    }

                    Button("경찰 마피아 못찾음") {
                        Task { await HapticPattern.policeNotFoundMafia.play() }
                    }
                }
            }
        }
    }
}

#Preview {
    HapticCatalogView()
}
