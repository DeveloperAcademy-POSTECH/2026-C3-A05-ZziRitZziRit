//
//  Player.swift
//  Mayoty
//
//  Created by sun on 6/1/26.
//

import Foundation
import Observation

@Observable
final class Player: Identifiable {
    let id: UUID

    var color: PlayerColor?
    var role: Role?
    var isAlive: Bool

    let watchId: String?

    /// 게임 시작 시 배정되는 HomeKit 조명 식별자 — 순서가 아닌 ID로 매핑해
    /// 조명 재발견/순서 변화에도 플레이어-조명 대응이 유지됨
    var lightId: String?

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
