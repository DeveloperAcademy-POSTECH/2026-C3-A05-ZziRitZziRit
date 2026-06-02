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
        //    private let colors : [Color] = [.white, .yellow, .red]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(haptics, id: \.0) { name, type in
                    Button(name) {
                        WKInterfaceDevice.current().play(type)
                    }
                }
                
                Button("Mixed (click → click → click → failure)") {
                    Task {
                        let device = WKInterfaceDevice.current()
                        for _ in 0..<3 {
                            device.play(.click)
                            try? await Task.sleep(for: .milliseconds(250))
                        }
                        try? await Task.sleep(for: .milliseconds(200))
                        device.play(.failure)
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Start Game") {
                    Task {
                        let device = WKInterfaceDevice.current()
                        for _ in 0..<2 {
                            device.play(.failure)
                            try? await Task.sleep(for: .milliseconds(700))
                            device.play(.start)
                            try? await Task.sleep(for: .milliseconds(400))
                        }
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Reveal Role") {
                    Task {
                        let device = WKInterfaceDevice.current()
                        for _ in 0..<8 { // 8 -> until click confirm button
                            device.play(.success)
                            try? await Task.sleep(for: .milliseconds(600))
                        }
                    }
                }
                
                Button("Role Time to Action") {
                    Task {
                        let device = WKInterfaceDevice.current()
                        for _ in 0..<3 {
                            device.play(.directionUp)
                            try? await Task.sleep(for: .milliseconds(400))
                        }
                    }
                }
                
                Button("Choose Player") {
                    Task {
                        let device = WKInterfaceDevice.current()
                        
                        device.play(.click)
                    }
                }
                
                Button("Confirm Choose Player") {
                    Task {
                        let device = WKInterfaceDevice.current()
                        
                        device.play(.directionUp)
                    }
                }
                
                VStack {
                    ProgressView("남은 시간", value: downloadAmount, total: 100)
                        .padding()
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: progressColor)
                        )
                }
                
                Button("Time Remaining 5seconds") {
                    let device = WKInterfaceDevice.current()
                    
                    Task{
                        while downloadAmount <= 100 {
                            downloadAmount -= 1
                            try? await Task.sleep(for: .milliseconds(100))
                            
                            if downloadAmount == 0 {
                                break
                            }
                            
                            if downloadAmount <= 50 && Int(downloadAmount) % 10 == 0 {
                                Task{
                                    device.play(.retry)
                                }
                                
                               
                            }
                        }
                        downloadAmount = 100
                    }
                }
                
                Button("Dead") {
                    let device = WKInterfaceDevice.current()
                    
                    Task{
                        for _ in 0..<3 {
                            device.play(.stop)
                            try? await Task.sleep(for: .milliseconds(1000))
                        }
                        device.play(.start)
                        try? await Task.sleep(for: .milliseconds(600))
                    }
                }
                
                Button("Victory") {
                    let device = WKInterfaceDevice.current()
                    
                    Task{
                        for _ in 0..<3 {
                            for _ in 0..<3 {
                                device.play(.directionUp)
                                try? await Task.sleep(for: .milliseconds(400))
                            }
                            try? await Task.sleep(for: .milliseconds(700))
                        }
                    }
                }
                
                Button("Lose") {
                    let device = WKInterfaceDevice.current()
                    
                    Task {
                        for _ in 0..<2 {
                            for _ in 0..<4 {
                                device.play(.failure)
                            }
                            try? await Task.sleep(for: .milliseconds(400))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HapticCatalogView()
}
