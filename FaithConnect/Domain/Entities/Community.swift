//
//  Community.swift
//  FaithConnect
//

import Foundation

enum Community: String, CaseIterable, Identifiable, Codable {
    case joseph = "JOSEPH"
    case david = "DAVID"
    case esther = "ESTHER"
    case joshua = "JOSHUA"
    case daniel = "DANIEL"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .joseph: return "요셉"
        case .david: return "다윗"
        case .esther: return "에스더"
        case .joshua: return "여호수아"
        case .daniel: return "다니엘"
        }
    }

    var emoji: String {
        switch self {
        case .joseph: return "🌾"
        case .david: return "🎵"
        case .esther: return "👑"
        case .joshua: return "⚔️"
        case .daniel: return "🦁"
        }
    }
}
