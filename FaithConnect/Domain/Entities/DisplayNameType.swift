//
//  DisplayNameType.swift
//  FaithConnect
//

import Foundation

enum DisplayNameType: String, CaseIterable, Codable {
    case nickname = "NICKNAME"
    case realName = "REAL_NAME"

    var displayName: String {
        self == .realName ? "실명" : "닉네임"
    }
}
