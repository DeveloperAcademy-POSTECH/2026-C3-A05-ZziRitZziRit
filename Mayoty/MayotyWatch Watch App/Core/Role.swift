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
    case citizen
}

extension Role {
    var displayName: String {
        switch self {
            case .mafia: "마피아"
            case .police: "경찰"
            case .doctor: "의사"
            case .citizen: "시민"
        }
    }
    
    var iconName: String {
        switch self {
            case .mafia: "hat.widebrim"
            case .police: "shield.pattern.checkered"
            case .doctor: "stethoscope"
            case .citizen: "person.crop.circle"
        }
    }
}
