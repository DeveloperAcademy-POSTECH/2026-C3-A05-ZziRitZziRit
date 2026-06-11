//
//  SoundManager.swift
//  Mayoty
//
//  Created by sun on 6/9/26.
//

import Foundation

final class SoundManager {

    // MARK: - Waiting

    func playGameStartSoundAndWait() async {
        await GameAudioManager.shared.playNarrationAndWait(named: "startGame")
    }

    // MARK: - Role Assigning

    func playRoleAssigningSounds() {
        GameAudioManager.shared.playNarrationsInOrder(named: [
            "rolesAssigned-introduction",
            "rolesAssigned-mafia",
            "rolesAssigned-police",
            "rolesAssigned-doctor",
            "rolesAssigned-completed"
        ])
        
        GameAudioManager.shared.playBGM(named: "nightBgm")
    }

    // MARK: - Introduction

    func playIntroductionEndingSound(after seconds: TimeInterval) {
        GameAudioManager.shared.playNarrationAfterDelay(
            named: "introductionEnded",
            delay: seconds
        )
    }
    
    func playIntroductionStartBgm(){
        GameAudioManager.shared.playBGM(named: "discussionBgm")
    }

    // MARK: - Night

    func playNightBgm() {
        GameAudioManager.shared.playBGM(named: "nightBgm")
    }

    // MARK: - Mafia

    func playMafiaStartSound() {
        GameAudioManager.shared.playNarration(named: "mafiaSelected")
    }
    
    func playMafiaEndSoundAndWait() async {
        await GameAudioManager.shared.playNarrationAndWait(named: "closeEyes-mafia")
    }

    // MARK: - Police

    func playPoliceStartSound() {
        GameAudioManager.shared.playNarration(named: "policeSelected")
    }
    
    func playPoliceEndSoundAndWait() async {
        await GameAudioManager.shared.playNarrationAndWait(named: "closeEyes-police")
    }

    // MARK: - Doctor

    func playDoctorStartSound() {
        GameAudioManager.shared.playNarration(named: "doctorSelected")
    }
    
    func playDoctorEndSoundAndWait() async {
        await GameAudioManager.shared.playNarrationAndWait(named: "closeEyes-doctor")
    }

    // MARK: - Discussion

    func playDiscussionStartSound(game: MafiaGame) {
        // 직전 밤 희생자만 발표 — 이전 라운드 사망자를 다시 읽으면 안 됨
        guard
            let deadPlayer = game.lastNightVictim,
            let color = deadPlayer.color
        else {
            GameAudioManager.shared.playNarration(named: "discussionEnded-NobodyDead")
            GameAudioManager.shared.playBGM(named: "discussionBgm")
            return
        }

        GameAudioManager.shared.playNarration(
            named: "discussionEnded-\(color.rawValue)Dead"
        )

        GameAudioManager.shared.playBGM(named: "discussionBgm")
    }

    // MARK: - Vote

    func playVoteStartSound() {
        GameAudioManager.shared.playNarration(named: "voteSubmitted")
    }

    func playVoteCompletedSoundAndWait(fileName: String) async {
        await GameAudioManager.shared.playNarrationAndWait(named: fileName)
    }
    
    func playFinalDefenseBgm() {
        GameAudioManager.shared.playBGM(named: "finalDefenseBgm")
    }
    
    // MARK: - FinalDefense
    
    func playFinalDefenseEndingSound(after seconds: TimeInterval) {
        GameAudioManager.shared.playNarrationAfterDelay(
            named: "finalDefenseEnded",
            delay: seconds
        )
    }
    
    // MARK: - Execution Vote

    func playExecutionVoteStartSound(game: MafiaGame) {
        guard
            let finalDefensePlayer = game.finalDefensePlayer,
            let color = finalDefensePlayer.color
        else {
            return
        }

        GameAudioManager.shared.playNarration(
            named: "executionVoteSubmitted-\(color.rawValue)"
        )
    }
    
    // MARK: - Execution Result

    func playExecutionResultSound(game: MafiaGame) {
        guard
            let finalDefensePlayer = game.finalDefensePlayer,
            let color = finalDefensePlayer.color
        else {
            return
        }

        let result = game.voteManager.shouldBeExecuted
            ? "Dead"
            : "Survived"

        GameAudioManager.shared.playNarration(
            named: "executionVoteCompleted-\(color.rawValue)\(result)"
        )
    }
    
    func playGunSoundEffect() {
        GameAudioManager.shared.playSoundEffect(named: "gunSoundEffect")
    }
    
    // MARK: - Result

    func playResultSound(winner: Team) {
        let narrationFileName: String
        let bgmFileName: String

        switch winner {
        case .citizens:
            narrationFileName = "gameEnded-citizenVictory"
            bgmFileName = "citizenVictoryBgm"

        case .mafia:
            narrationFileName = "gameEnded-mafiaVictory"
            bgmFileName = "mafiaVictoryBgm"
        }

        GameAudioManager.shared.playNarration(
            named: narrationFileName
        )
        
        GameAudioManager.shared.playBGM(
            named: bgmFileName
        )
    }

    func stopAll() {
        GameAudioManager.shared.stopAll()
    }
}
