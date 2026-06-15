    //
    //  HapticPattern.swift
    //  MayotyWatch Watch App
    //
    //  Created by 이경민 on 6/2/26.
    //

import SwiftUI

enum HapticPattern {
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
    case connectionSucceed
    case connectionFail
    case policeFoundMafia
    case policeNotFoundMafia
    
    func play() async throws{
        let device = WKInterfaceDevice.current()
        
        switch self {
            case .startGame:
                for _ in 0..<2 {
                    device.play(.failure)
                    try await Task.sleep(for: .milliseconds(700))
                    device.play(.start)
                    try await Task.sleep(for: .milliseconds(400))
                }
                
            case .revealRole:
                for _ in 0..<8 { // 8 -> until click confirm button
                    device.play(.success)
                    try await Task.sleep(for: .milliseconds(600))
                }
                
            case .roleTimeToAction:
                for _ in 0..<3 {
                    device.play(.directionUp)
                    try await Task.sleep(for: .milliseconds(400))
                }
                
            case .choosePlayer:
                device.play(.click)
                
            case .confirmChoosPlayer:
                device.play(.directionUp)
                
            case .timeRemaining:
                device.play(.retry)
                
            case .dead:
                for _ in 0..<3 {
                    device.play(.stop)
                    try await Task.sleep(for: .milliseconds(1000))
                }
                device.play(.start)
                try await Task.sleep(for: .milliseconds(600))
                
            case .citizenWin:
                for _ in 0..<8 {
                    for _ in 0..<3 {
                        device.play(.directionUp)
                        try await Task.sleep(for: .milliseconds(400))
                    }
                    try await Task.sleep(for: .milliseconds(600))
                }
                
            case .mafiaWin:
                device.play(.click)
                try await Task.sleep(for: .milliseconds(1000))
                device.play(.click)
                try await Task.sleep(for: .milliseconds(800))
                device.play(.click)
                try await Task.sleep(for: .milliseconds(600))
                device.play(.click)
                try await Task.sleep(for: .milliseconds(400))
                device.play(.click)
                try await Task.sleep(for: .milliseconds(300))
                for _ in 0..<6{
                    device.play(.click)
                    try await Task.sleep(for: .milliseconds(200))
                }
                for _ in 0..<8 {
                    try await Task.sleep(for: .milliseconds(400))
                    device.play(.success)
                    try await Task.sleep(for: .milliseconds(400))
                    device.play(.success)
                    try await Task.sleep(for: .milliseconds(400))
                    device.play(.success)
                    try await Task.sleep(for: .milliseconds(800))
                }
                
            case .circularProgress:
                while true {
                    device.play(.directionUp)
                    try await Task.sleep(for: .milliseconds(500))
                }
            case .connectionSucceed:
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
