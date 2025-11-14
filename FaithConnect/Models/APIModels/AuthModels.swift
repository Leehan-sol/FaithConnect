//
//  AuthModels.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

struct SignUpRequest: Codable {
    let churchMemberId: String
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
}

struct SignUpResponse: Decodable {
    let message: String
    let success: Bool
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
