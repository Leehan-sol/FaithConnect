//
//  Visibility.swift
//  FaithConnect
//

import Foundation

enum Visibility: String, CaseIterable, Identifiable, Codable {
    case publicAll = "PUBLIC"
    case pastorOnly = "PASTOR_ONLY"
    case privateOnly = "PRIVATE"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .publicAll: return "전체 공개"
        case .pastorOnly: return "목회자에게만"
        case .privateOnly: return "나만 보기"
        }
    }

    var icon: String {
        switch self {
        case .publicAll: return ""
        case .pastorOnly: return "🔒"
        case .privateOnly: return "🔐"
        }
    }
}
