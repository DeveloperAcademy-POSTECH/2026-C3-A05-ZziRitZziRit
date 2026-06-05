//
//  GameLightColor.swift
//  Mayoty
//
//  Created by sun on 6/5/26.
//

enum GameLightColor {
    case mafiaWin
    case citizenWin
    
    var hue: Double {
        switch self {
        case .mafiaWin: return 0
        case .citizenWin: return 120
        }
    }
    var saturation: Double { 100 }
}
