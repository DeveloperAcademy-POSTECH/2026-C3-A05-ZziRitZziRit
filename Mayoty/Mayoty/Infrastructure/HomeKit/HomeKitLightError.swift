//
//  HomeKitLightError.swift
//  Mayoty
//
//  Created by sun on 6/5/26.
//

import Foundation

enum HomeKitLightError: LocalizedError {
    case powerNotSupported
    case colorNotSupported
    case brightnessNotSupported

    var errorDescription: String? {
        switch self {
        case .powerNotSupported:
            "전원 제어 항목을 찾지 못했습니다."
        case .colorNotSupported:
            "색상 제어 항목을 찾지 못했습니다."
        case .brightnessNotSupported:
            "밝기 제어 항목을 찾지 못했습니다."
        }
    }
}
