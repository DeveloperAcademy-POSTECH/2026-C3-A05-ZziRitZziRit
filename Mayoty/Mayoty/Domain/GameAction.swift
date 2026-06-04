//
//  GameAction.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

enum GameAction {
    case startGame
    case rolesAssigned
    case introductionEnded

    case mafiaSelected(target: Player)
    case policeSelected(target: Player)
    case doctorSelected(target: Player)

    case discussionEnded
    case voteSubmitted(voter: Player, target: Player)
    case voteCompleted

    case finalDefenseEnded
    case executionVoteSubmitted(voter: Player, isAgree: Bool)
    case executionVoteCompleted
    case gameEnded
}
