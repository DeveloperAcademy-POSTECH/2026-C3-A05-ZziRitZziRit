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
}
