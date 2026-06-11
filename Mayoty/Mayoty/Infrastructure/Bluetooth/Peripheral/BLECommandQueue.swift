//
//  BLECommandQueue.swift
//  Mayoty
//
//  Created by Claude on 6/11/26.
//

import Foundation

/// CoreBluetooth updateValue가 false(내부 전송 큐 가득)를 반환했을 때
/// 명령이 유실되지 않도록 FIFO 순서를 보장하는 재전송 큐
///
/// 전송 함수를 주입받는 구조라 CoreBluetooth 없이도 검증 가능 (Tools/FlowSim)
final class BLECommandQueue {

    struct Entry {
        let data: Data
        let centralID: UUID?
        let label: String
    }

    /// 전송 시도 함수 — 성공 시 true, 큐 가득이면 false
    typealias Send = (Entry) -> Bool

    private(set) var pending: [Entry] = []

    /// 전송 시도. 이미 대기 중인 명령이 있으면 순서 보장을 위해 뒤에 줄 세우고,
    /// 전송이 실패해도 큐에 보관한다.
    /// - Returns: 즉시 전송에 성공했으면 true
    @discardableResult
    func send(_ entry: Entry, using send: Send) -> Bool {
        guard pending.isEmpty else {
            pending.append(entry)
            return false
        }

        guard send(entry) else {
            pending.append(entry)
            return false
        }

        return true
    }

    /// 전송 큐에 자리가 생겼을 때 대기 명령을 순서대로 재전송.
    /// 중간에 다시 실패하면 남은 항목은 보존된다.
    func flush(using send: Send) {
        while let next = pending.first {
            guard send(next) else { return }
            pending.removeFirst()
        }
    }

    func removeAll() {
        pending.removeAll()
    }
}
