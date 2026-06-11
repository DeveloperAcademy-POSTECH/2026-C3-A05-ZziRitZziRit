//
//  PlayerColor.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

// iPhone·Watch 두 타깃이 공유하는 파일 — 플랫폼 의존 확장은
// PlayerColor+HomeKitColor.swift(iPhone), PlayerColor+Watch.swift(Watch)에 분리
enum PlayerColor: String, Codable, CaseIterable {
    case pink
    case purple
    case yellow
    case mint
    case orange
}
