//
//  Role.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

enum Role: Codable {
    case citizen
    case mafia
    case police
    case doctor
    
    var team: Team {
        switch self {
        case .mafia:
            return .mafia
        case .citizen, .police, .doctor:
            return .citizens
        }
    }
    
    var displayName: String {
            switch self {
            case .citizen:
                return "시민"
            case .mafia:
                return "마피아"
            case .police:
                return "경찰"
            case .doctor:
                return "의사"
            }
        }
}
