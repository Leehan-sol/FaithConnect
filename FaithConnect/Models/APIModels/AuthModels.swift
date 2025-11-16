//
//  AuthModels.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

struct SignUpRequest: Codable {
    let churchMemberId: Int
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

struct FindIDRequest: Codable {
    let name: String
    let churchMemberId: Int
}

struct FindIDResponse: Decodable {
    let email: String
    let success: Bool
}
