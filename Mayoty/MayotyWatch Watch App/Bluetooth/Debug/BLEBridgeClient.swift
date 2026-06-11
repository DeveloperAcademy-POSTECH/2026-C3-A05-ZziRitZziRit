//
//  BLEBridgeClient.swift
//  MayotyWatch Watch App
//
//  Created by Claude on 6/11/26.
//

#if DEBUG
import Foundation
import Network

/// 시뮬레이터 데모용 가상 전송 — BLE 대신 로컬 TCP로 iPhone 앱과 통신
///
/// 시뮬레이터는 Bluetooth를 지원하지 않으므로, `-blebridge` 런치 인자를 주면
/// CBCentralManager 대신 이 클라이언트가 같은 이벤트를 발생시킨다.
final class BLEBridgeClient {

    static let port: UInt16 = 18790

    private var connection: NWConnection?

    var onCommand: ((BLECommand) -> Void)?
    var onStateChange: ((WatchConnectionState) -> Void)?

    func connect() {
        guard connection == nil else { return }

        let connection = NWConnection(
            host: "127.0.0.1",
            port: NWEndpoint.Port(rawValue: Self.port)!,
            using: .tcp
        )

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                GameLogger.bluetooth("[bridge] iPhone 연결됨")
                self?.onStateChange?(.connected)
                self?.send(.join())
                self?.receive(on: connection)

            case .waiting:
                self?.onStateChange?(.connecting)

            case .failed, .cancelled:
                self?.scheduleReconnect()

            default:
                break
            }
        }

        self.connection = connection
        onStateChange?(.scanning)
        connection.start(queue: .main)
    }

    private func scheduleReconnect() {
        guard connection != nil else { return }

        connection?.cancel()
        connection = nil
        onStateChange?(.disconnected)

        GameLogger.bluetooth("[bridge] 1초 후 재연결")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.connect()
        }
    }

    private func receive(on connection: NWConnection) {
        connection.receive(
            minimumIncompleteLength: 3,
            maximumLength: 3
        ) { [weak self] data, _, isComplete, error in
            guard let self else { return }

            if let data, let command = BLECommand(data: data) {
                GameLogger.bluetooth("[bridge] command 수신: \(command.kind)")
                self.onCommand?(command)
            }

            if isComplete || error != nil {
                self.scheduleReconnect()
                return
            }

            self.receive(on: connection)
        }
    }

    func send(_ answer: BLEAnswer) {
        connection?.send(
            content: answer.data,
            completion: .contentProcessed { _ in }
        )
    }
}
#endif
