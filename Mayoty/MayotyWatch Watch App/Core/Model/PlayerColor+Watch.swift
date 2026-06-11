//
//  PlayerColor+Watch.swift
//  MayotyWatch Watch App
//
//  Created by Claude on 6/11/26.
//

import SwiftUI

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
