//
//  HomeKitLightColor.swift
//  Mayoty
//
//  Created by sun on 6/6/26.
//

enum HomeKitLightColor {
    case playerPink
    case playerPurple
    case playerYellow
    case playerMint
    case playerOrange

    case mafiaWin
    case citizenWin

    var hue: Double {
        switch self {
        case .playerPink: return 330
        case .playerPurple: return 270
        case .playerYellow: return 60
        case .playerMint: return 150
        case .playerOrange: return 30
        case .mafiaWin: return 0
        case .citizenWin: return 120
        }
    }

    var saturation: Double { 100 }
    var brightness: Double { 100 }
}
