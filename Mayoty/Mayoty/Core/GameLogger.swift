//
//  GameLogger.swift
//  Mayoty
//
//  Created by sun on 6/6/26.
//

enum GameLogger {
    static func log(_ message: String) {
        print("🎮 \(message)")
    }

    static func stateChanged(
        from oldState: Any,
        to newState: Any
    ) {
        log("상태 변경: \(type(of: oldState)) → \(type(of: newState))")
    }

    static func action(_ action: Any) {
        log("액션 발생: \(action)")
    }

    static func event(_ message: String) {
        print("\(message)")
    }

    static func timer(_ message: String) {
        print("⏱️ \(message)")
    }

    static func light(_ message: String) {
        print("💡 \(message)")
    }

    static func bluetooth(_ message: String) {
        print("📡 \(message)")
    }

    static func result(_ message: String) {
        print("🏆 \(message)")
    }
}
