//
//  User.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/21.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String // churchMemberId
    let name: String
    let email: String
    let accessToken: String
    let refreshToken: String
}
