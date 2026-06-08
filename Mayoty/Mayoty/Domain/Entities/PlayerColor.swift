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
    var homeKitColor: HomeKitLightColor {
        switch self {
        case .pink:
            return .playerPink
        case .purple:
            return .playerPurple
        case .yellow:
            return .playerYellow
        case .mint:
            return .playerMint
        case .orange:
            return .playerOrange
        }
    }
}
