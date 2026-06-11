//
//  PlayerColor+HomeKitColor.swift
//  Mayoty
//
//  Created by Claude on 6/11/26.
//

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
