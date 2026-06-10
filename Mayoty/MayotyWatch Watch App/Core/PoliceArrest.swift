//
//  PoliceArrest.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

enum PoliceArrest: Codable {
    case success
    case fail

}

extension PoliceArrest {
    var resultText: String {
        switch self {
            case .success: return "성공"
            case .fail: return "실패"
        }
    }

    var resultColor: Color {
        switch self {
        case .success: return .green
        case .fail: return .red
        }
    }
}
