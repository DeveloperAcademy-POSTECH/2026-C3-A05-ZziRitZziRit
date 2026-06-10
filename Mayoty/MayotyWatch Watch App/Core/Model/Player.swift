//
//  Player.swift
//  Mayoty
//
//  Created by sun on 6/8/26.
//

import Foundation

final class Player: Identifiable {
    let id: UUID

    var color: PlayerColor?
    var role: Role?
    var isAlive: Bool

    let watchId: String?
    let lightId: String?

    init(
        id: UUID = UUID(),
        color: PlayerColor? = nil,
        role: Role? = nil,
        isAlive: Bool = true,
        watchId: String? = nil,
        lightId: String? = nil
    ) {
        self.id = id
        self.color = color
        self.role = role
        self.isAlive = isAlive
        self.watchId = watchId
        self.lightId = lightId
    }
}
