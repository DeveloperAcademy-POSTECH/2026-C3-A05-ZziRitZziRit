//
//  PlayerColor.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import SwiftUI

enum PlayerColor: String, Codable, CaseIterable {
    case pink
    case purple
    case yellow
    case mint
    case orange
}

extension PlayerColor {
    var uiColor: Color {
        switch self {
        case .pink:   return .hmPink
        case .purple: return .hmViolet
        case .yellow: return .hmYellow
        case .mint:   return .hmMint
        case .orange: return .hmOrange
        }
    }

    var displayName: String {
        switch self {
        case .pink:   return "핑크색"
        case .purple: return "보라색"
        case .yellow: return "노란색"
        case .mint:   return "민트색"
        case .orange: return "주황색"
        }
    }
}
