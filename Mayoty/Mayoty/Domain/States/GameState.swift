//
//  GameState.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

protocol GameState {
    func enter()
    func handleAction(_ action: GameAction)
    func exit()
}
