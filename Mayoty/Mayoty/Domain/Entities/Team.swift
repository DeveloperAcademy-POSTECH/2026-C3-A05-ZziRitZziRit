//
//  Team.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

enum Team: Codable {
    case citizens
    case mafia
    
    var displayName: String {
        switch self {
        case .citizens:
            return "시민 승리"
        case .mafia:
            return "마피아 승리"
        }
    }
}
