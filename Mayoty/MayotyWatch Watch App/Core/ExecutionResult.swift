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
            case .survive: .green
            case .dead: .red
        }
    }
    var textResult: String {
        switch self {
            case .survive: "생존"
            case .dead: "사망"
        }
    }
}
