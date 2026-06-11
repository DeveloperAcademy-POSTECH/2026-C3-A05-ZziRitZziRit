//
//  Role+Watch.swift
//  MayotyWatch Watch App
//
//  Created by Claude on 6/11/26.
//

extension Role {
    var iconName: String {
        switch self {
            case .mafia: "mafia"
            case .police: "police"
            case .doctor: "doctor"
            case .citizen: "citizen"
        }
    }

    var selectingText: String {
        switch self {
            case .mafia: "죽일 사람을 지목하세요"
            case .police: "조사할 사람을 지목하세요"
            case .doctor: "살릴 사람을 지목하세요"
            case .citizen: "죽일 사람을 지목하세요"
        }
    }
}

extension Role {
    init?(bleValue: UInt8) {
        switch bleValue {
        case 1:
            self = .mafia
        case 2:
            self = .police
        case 3:
            self = .doctor
        case 4:
            self = .citizen
        default:
            return nil
        }
    }
}
