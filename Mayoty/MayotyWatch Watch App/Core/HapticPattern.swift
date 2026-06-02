//
//  HapticPattern.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/2/26.
//

import SwiftUI

enum HapticCatalog {
    case startGame
    case revealRole
    case roleTimeToAction
    case choosePlayer
    case confirmChoosPlayer
    case timeRemaining
    case dead
    case citizenWin
    case mafiaWin
    case circularProgress
    case connectionOk
    case connectionFail
    case policeFoundMafia
    case policeNotFoundMafia
    
    func play() async {
        let device = WKInterfaceDevice.current()
        
        @State var downloadAmount : Double = 100
        var progressColor : Color {
            if downloadAmount > 50 {
                return .purple1
            } else if downloadAmount <= 50 && downloadAmount > 20 {
                return .purple2
            } else if downloadAmount <= 20 {
                return .purple3
            }
            return .purple
        }
        switch self {
            case .startGame:
                Task {
                    let device = WKInterfaceDevice.current()
                    for _ in 0..<2 {
                        device.play(.failure)
                        try? await Task.sleep(for: .milliseconds(700))
                        device.play(.start)
                        try? await Task.sleep(for: .milliseconds(400))
                    }
                }
                
            case .revealRole:
                Task {
                    let device = WKInterfaceDevice.current()
                    for _ in 0..<8 { // 8 -> until click confirm button
                        device.play(.success)
                        try? await Task.sleep(for: .milliseconds(600))
                    }
                }
                
            case .roleTimeToAction:
                Task {
                    let device = WKInterfaceDevice.current()
                    for _ in 0..<3 {
                        device.play(.directionUp)
                        try? await Task.sleep(for: .milliseconds(400))
                    }
                }
                
            case .choosePlayer:
                Task {
                    let device = WKInterfaceDevice.current()
                    
                    device.play(.click)
                }
                
            case .confirmChoosPlayer:
                Task {
                    let device = WKInterfaceDevice.current()
                    
                    device.play(.directionUp)
                }
                
            case .timeRemaining:
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
                
            case .dead:
                let device = WKInterfaceDevice.current()
                
                Task{
                    for _ in 0..<3 {
                        device.play(.stop)
                        try? await Task.sleep(for: .milliseconds(1000))
                    }
                    device.play(.start)
                    try? await Task.sleep(for: .milliseconds(600))
                }
                
            case .citizenWin:
                Task{
                    for _ in 0..<8 {
                        for _ in 0..<3 {
                            device.play(.directionUp)
                            try? await Task.sleep(for: .milliseconds(400))
                        }
                        try? await Task.sleep(for: .milliseconds(600))
                    }
                }
                
            case .mafiaWin:
                Task {
                    device.play(.click)
                    try? await Task.sleep(for: .milliseconds(1000))
                    device.play(.click)
                    try? await Task.sleep(for: .milliseconds(800))
                    device.play(.click)
                    try? await Task.sleep(for: .milliseconds(600))
                    device.play(.click)
                    try? await Task.sleep(for: .milliseconds(400))
                    device.play(.click)
                    try? await Task.sleep(for: .milliseconds(300))
                    for _ in 0..<6{
                        device.play(.click)
                        try? await Task.sleep(for: .milliseconds(200))
                    }
                    for _ in 0..<8 {
                        try? await Task.sleep(for: .milliseconds(400))
                        device.play(.success)
                        try? await Task.sleep(for: .milliseconds(400))
                        device.play(.success)
                        try? await Task.sleep(for: .milliseconds(400))
                        device.play(.success)
                        try? await Task.sleep(for: .milliseconds(800))
                    }
                    
                }
                
            case .circularProgress:
                device.play(.directionUp)
                device.play(.start)
            case .connectionOk:
                device.play(.directionUp)
            case .connectionFail:
                device.play(.failure)
            case .policeFoundMafia:
                device.play(.success)
            case .policeNotFoundMafia:
                device.play(.failure)
        }
    }
}
