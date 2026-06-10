//
//  Victory.swift
//  MayotyWatch Watch App
//
//  Created by 이경민 on 6/11/26.
//

import SwiftUI

enum Victory: Codable {
    case mafia
    case citizen
}

extension Victory {
    var text: String {
        switch self {
            case .mafia: "마피아 승리"
            case .citizen : "시민 승리"
        }
    }
    
    @ViewBuilder
    func animation<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        switch self {
            case .mafia: BloodAnimationView { content() }
            case .citizen: ConfettiAnimationView { content() }
        }
    }
    
    var backGroundColor: Color {
        switch self {
            case .mafia: .bgMafia
            case .citizen: .bgCitizen
        }
    }
    
    var textColor: Color {
        switch self {
            case .mafia: .red
            case .citizen: .green
        }
    }
    
    var haptic: HapticPattern {
        switch self {
            case .mafia: .mafiaWin
            case .citizen: .citizenWin
        }
    }
}
