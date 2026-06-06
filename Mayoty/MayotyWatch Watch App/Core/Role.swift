    //
    //  Role.swift
    //  MayotyWatch Watch App
    //
    //  Created by 이경민 on 6/5/26.
    //

import SwiftUI

enum Role: Codable {
    case mafia
    case police
    case doctor
}

extension Role {
    var displayName: String {
        switch self {
            case .mafia:   return "마피아"
            case .police:  return "경찰"
            case .doctor:  return "의사"
        }
    }
    
    var iconName: String {
        switch self {
            case .mafia:   return "hat.widebrim"
            case .police:  return "shield.pattern.checkered"
            case .doctor:  return "stethoscope"
        }
    }
}
