//
//  HomeKitLightError.swift
//  Mayoty
//
//  Created by sun on 6/5/26.
//

import Foundation

enum HomeKitLightError: Error {
    case powerNotSupported
    
    var errorDescription: String? {
        switch self {
        case .powerNotSupported:
            return "전원 제어 항목을 찾지 못했습니다."
        }
    }
}
