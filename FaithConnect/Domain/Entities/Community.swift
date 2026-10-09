//
//  Community.swift
//  FaithConnect
//

import Foundation

struct CommunityItem: Identifiable, Equatable {
    let community: String
    let displayName: String

    var id: String { community }
}

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
}
