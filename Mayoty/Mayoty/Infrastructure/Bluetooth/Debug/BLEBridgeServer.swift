//
//  BLEBridgeServer.swift
//  Mayoty
//
//  Created by Claude on 6/11/26.
//

#if DEBUG
import Foundation
import Network

/// 시뮬레이터 데모용 가상 전송 — BLE 대신 로컬 TCP로 Watch 앱과 통신
///
/// 시뮬레이터는 Bluetooth를 지원하지 않으므로, `-blebridge` 런치 인자를 주면
/// CBPeripheralManager 대신 이 서버가 같은 이벤트를 발생시킨다.
/// 프로토콜은 실제와 동일한 BLECommand(3바이트)/BLEAnswer(2바이트) 프레임.
final class BLEBridgeServer {

    static let port: UInt16 = 18790

    private var listener: NWListener?
    private var connections: [UUID: NWConnection] = [:]

    var onWatchConnected: ((UUID) -> Void)?
    var onWatchDisconnected: ((UUID) -> Void)?
    var onAnswer: ((UUID, BLEAnswer) -> Void)?

    func start() {
        guard listener == nil else { return }

        guard let listener = try? NWListener(
            using: .tcp,
            on: NWEndpoint.Port(rawValue: Self.port)!
        ) else {
            GameLogger.bluetooth("[bridge] 서버 시작 실패")
            return
        }

        listener.newConnectionHandler = { [weak self] connection in
            self?.accept(connection)
        }

        listener.start(queue: .main)
        self.listener = listener

        GameLogger.bluetooth("[bridge] TCP 서버 시작 :\(Self.port)")
    }

    private func accept(_ connection: NWConnection) {
        let id = UUID()
        connections[id] = connection

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                GameLogger.bluetooth("[bridge] watch 연결: \(id.uuidString.prefix(8))")
                self?.onWatchConnected?(id)
                self?.receive(on: connection, id: id)

            case .failed, .cancelled:
                self?.dropConnection(id)

            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    private func dropConnection(_ id: UUID) {
        guard connections.removeValue(forKey: id) != nil else { return }

        GameLogger.bluetooth("[bridge] watch 해제: \(id.uuidString.prefix(8))")
        onWatchDisconnected?(id)
    }

    private func receive(on connection: NWConnection, id: UUID) {
        connection.receive(
            minimumIncompleteLength: 2,
            maximumLength: 2
        ) { [weak self] data, _, isComplete, error in
            guard let self else { return }

            if let data, let answer = BLEAnswer(data: data) {
                self.onAnswer?(id, answer)
            }

            if isComplete || error != nil {
                self.dropConnection(id)
                return
            }

            self.receive(on: connection, id: id)
        }
    }

    func send(_ data: Data, to centralID: UUID?) {
        if let centralID {
            connections[centralID]?.send(
                content: data,
                completion: .contentProcessed { _ in }
            )
        } else {
            for connection in connections.values {
                connection.send(
                    content: data,
                    completion: .contentProcessed { _ in }
                )
            }
        }
    }
}
#endif
