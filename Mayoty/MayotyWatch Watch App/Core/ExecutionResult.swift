//
//  ExecutionResult.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/5/26.
//

import SwiftUI

enum ExecutionResult {
    case survive
    case dead
}

extension ExecutionResult {
    var textColor: Color {
        switch self {
            case .survive: return .green
            case .dead: return .red
        }
    }
    var textResult: String {
        switch self {
            case .survive: return "생존"
            case .dead: return "사망"
        }
    }
}
