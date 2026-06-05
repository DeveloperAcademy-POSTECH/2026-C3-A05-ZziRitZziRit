//
//  PlayerColor.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

enum PlayerColor: String, Codable, CaseIterable {
    case pink
    case purple
    case yellow
    case mint
    case orange
}

extension PlayerColor {
    var hue: Double {
        switch self {
        case .pink: return 330
        case .purple: return 270
        case .yellow: return 60
        case .mint: return 150
        case .orange: return 30
        }
    }
    
    var saturation: Double { 100 }
}
