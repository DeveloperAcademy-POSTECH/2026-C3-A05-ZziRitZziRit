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
            case .success: "성공"
            case .fail: "실패"
        }
    }

    var resultColor: Color {
        switch self {
        case .success: .green
        case .fail: .red
        }
    }
    
    var resultHaptic: HapticPattern {
        switch self {
            case .success: HapticPattern.policeFoundMafia
            case .fail: HapticPattern.policeNotFoundMafia
        }
    }
}
