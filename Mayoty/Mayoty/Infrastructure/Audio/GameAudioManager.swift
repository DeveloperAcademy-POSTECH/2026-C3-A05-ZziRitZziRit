//
//  GameAudioManager.swift
//  Mayoty
//
//  Created by sun on 6/9/26.
//

import AVFoundation

final class GameAudioManager {
    static let shared = GameAudioManager()

    private var bgmPlayer: AVAudioPlayer?

    private var narrationPlayer: AVAudioPlayer?
    private var narrationTask: Task<Void, Never>?

    private var effectPlayer: AVAudioPlayer?
    private var effectTask: Task<Void, Never>?

    private init() {}

    /// 오디오 세션 초기화
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            GameLogger.event("🎵 오디오 세션 설정 실패: \(error.localizedDescription)")
        }
    }

    /// BGM 반복 재생
    func playBGM(named fileName: String) {
        setupAudioSession()

        bgmPlayer?.stop()
        bgmPlayer = makePlayer(named: fileName)
        bgmPlayer?.numberOfLoops = -1
        bgmPlayer?.volume = 0.35
        bgmPlayer?.play()

        GameLogger.event("🎵 BGM 재생: \(fileName)")
    }

    /// 나레이션 순차 재생
    func playNarrationsInOrder(named fileNames: [String]) {
        setupAudioSession()

        narrationTask?.cancel()
        narrationPlayer?.stop()
        narrationPlayer = nil

        narrationTask = Task { [weak self] in
            guard let self else { return }

            for fileName in fileNames {
                guard !Task.isCancelled else { return }
                await self.playOneNarrationAndWait(named: fileName)
            }
        }
    }

    /// 나레이션 하나 재생
    func playNarration(named fileName: String) {
        playNarrationsInOrder(named: [fileName])
    }

    /// 일정 시간 후 나레이션 재생
    func playNarrationAfterDelay(
        named fileName: String,
        delay seconds: TimeInterval
    ) {
        narrationTask?.cancel()
        narrationPlayer?.stop()
        narrationPlayer = nil

        narrationTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(seconds))
                guard !Task.isCancelled else { return }

                await self?.playOneNarrationAndWait(named: fileName)
            } catch {
                return
            }
        }
    }

    /// 효과음 순차 재생
    func playSoundEffectsInOrder(named fileNames: [String]) {
        setupAudioSession()

        effectTask?.cancel()
        effectPlayer?.stop()
        effectPlayer = nil

        effectTask = Task { [weak self] in
            guard let self else { return }

            for fileName in fileNames {
                guard !Task.isCancelled else { return }
                await self.playOneEffectAndWait(named: fileName)
            }
        }
    }

    /// 효과음 하나 재생
    func playSoundEffect(named fileName: String) {
        playSoundEffectsInOrder(named: [fileName])
    }

    /// 모든 오디오 정지
    func stopAll() {
        narrationTask?.cancel()
        narrationTask = nil

        effectTask?.cancel()
        effectTask = nil

        bgmPlayer?.stop()

        narrationPlayer?.stop()
        narrationPlayer = nil

        effectPlayer?.stop()
        effectPlayer = nil

        GameLogger.event("🎵 모든 오디오 정지")
    }

    /// 단일 나레이션 재생 후 대기
    private func playOneNarrationAndWait(named fileName: String) async {
        guard !Task.isCancelled else { return }
        guard let player = makePlayer(named: fileName) else { return }

        narrationPlayer = player
        player.volume = 1.0
        player.play()

        GameLogger.event("🎵 나레이션 재생: \(fileName)")

        await sleepUntilFinished(player)
    }

    /// 단일 효과음 재생 후 대기
    private func playOneEffectAndWait(named fileName: String) async {
        guard !Task.isCancelled else { return }
        guard let player = makePlayer(named: fileName) else { return }

        effectPlayer = player
        player.volume = 0.8
        player.play()

        GameLogger.event("🎵 효과음 재생: \(fileName)")

        await sleepUntilFinished(player)
    }

    /// 오디오 길이만큼 대기
    private func sleepUntilFinished(_ player: AVAudioPlayer) async {
        let duration = UInt64(player.duration * 1_000_000_000)

        do {
            try await Task.sleep(nanoseconds: duration)
        } catch {
            player.stop()
        }
    }
    
    /// 나레이션 재생 완료 후 실행
    func playNarrationAndWait(named fileName: String) async {
        setupAudioSession()

        narrationTask?.cancel()
        narrationPlayer?.stop()
        narrationPlayer = nil

        await playOneNarrationAndWait(named: fileName)
    }

    /// 오디오 플레이어 생성
    private func makePlayer(named fileName: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: "mp3"
        ) else {
            GameLogger.event("🎵 오디오 파일 없음: \(fileName).mp3")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            GameLogger.event("🎵 오디오 재생 실패: \(error.localizedDescription)")
            return nil
        }
    }
}
