//
//  RoleManager.swift
//  Mayoty
//
//  Created by sun on 6/4/26.
//

final class RoleManager {
    func assignRoles(to players: [Player]) {
        let roles: [Role] = [
            .mafia,
            .police,
            .doctor,
            .citizen,
            .citizen
        ].shuffled()

        for (player, role) in zip(players, roles) {
            player.role = role
        }
    }
}
