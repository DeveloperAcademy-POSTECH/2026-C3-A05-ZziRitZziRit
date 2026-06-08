//
//  WatchBLEConnectionState.swift
//  Mayoty
//
//  Created by jeegarden on 6/5/26.
//

import Foundation

enum WatchConnectionState {
    case idle
    case bluetoothUnavailable
    case scanning
    case connecting
    case connected
    case disconnected
    case failed
    case unauthorized

    case sendAnswerSuccess
    case sendAnswerFailed

    var stateDescription: String {
        switch self {
        case .idle:
            return "Idle"
        case .bluetoothUnavailable:
            return "블루투스 사용 불가"
        case .scanning:
            return "디바이스 검색 중"
        case .connecting:
            return "연결 중"
        case .connected:
            return "연결 완료"
        case .disconnected:
            return "연결 해제"
        case .failed:
            return "연결 실패"
        case .unauthorized:
            return "권한 없음"
        case .sendAnswerSuccess:
            return "응답 보내기 성공"
        case .sendAnswerFailed:
            return "응답 보내기 실패"
        }
    }
}
