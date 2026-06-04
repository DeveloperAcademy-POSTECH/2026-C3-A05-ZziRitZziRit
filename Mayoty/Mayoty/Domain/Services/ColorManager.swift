//
//  ColorManager.swift
//  Mayoty
//
//  Created by sun on 6/4/26.
//

final class ColorManager {
    func assignColors(to players: [Player]) {
        let colors = PlayerColor.allCases.shuffled()

        for (player, color) in zip(players, colors) {
            player.color = color
        }
    }
}
