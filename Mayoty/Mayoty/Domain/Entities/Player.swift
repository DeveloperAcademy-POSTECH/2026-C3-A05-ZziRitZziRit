//
//  Player.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

import Foundation

struct Player: Identifiable, Codable {
    let id: UUID
    let color: PlayerColor
    
    var role: Role?
    var isAlive: Bool
    
    let watchId: String?
    let lightId: String?
    
    init(
        id: UUID = UUID(),
        color: PlayerColor
    ) {
        self.id = id
        self.color = color
        self.role = nil
        self.isAlive = true
        self.watchId = nil
        self.lightId = nil
    }
}
