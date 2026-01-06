//
//  AuthDTOs.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

// MARK: - 회원가입
struct SignUpRequest: Codable {
    let churchMemberId: Int
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
}

struct SignUpResponse: Decodable {
    let message: String
    let success: Bool?
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 로그인
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let name: String
    let email: String
    let accessToken: String
    let refreshToken: String
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 로그아웃
struct LogoutResponse: Decodable {
    let message: String
    let success: Bool
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 아이디 찾기
struct FindIDRequest: Codable {
    let name: String
    let churchMemberId: Int
}

struct FindIDResponse: Decodable {
    let email: String
    let success: Bool
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 비밀번호 변경
struct ChangePasswordRequest: Codable {
    let name: String
    let churchMemberId: Int
    let email: String
    let newPassword: String
}

struct ChangePasswordResponse: Decodable {
    let message: String
    let success: Bool
    let errorCode: APIErrorCode?
    let status: Int?
}


// MARK: - 토큰 요청
struct AccessTokenRequest: Codable {
    let refreshToken: String
}

struct AccessTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let errorCode: APIErrorCode?
    let status: Int?
}
