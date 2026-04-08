//
//  AuthDTOs.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

// MARK: - 회원가입
// TODO: 서버 API 변경 후 nickname 필드 추가 (name: 이름, nickname: 닉네임)
struct SignUpRequest: Codable {
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

// MARK: - 내 정보
struct FetchMyInfoResponse: Decodable {
    let name: String
    let email: String
}

// MARK: - 아이디 찾기
// TODO: 서버 API 변경 후 이름(name)으로 이메일 찾기 확정 (닉네임만으로는 보안 이슈)
struct FindIDRequest: Codable {
    let name: String
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


// MARK: - 회원탈퇴
struct DeleteAccountResponse: Decodable {
    let message: String
    let success: Bool?
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 비밀번호 재설정
struct PasswordResetRequest: Encodable {
    let email: String
}

struct PasswordResetResponse: Decodable {
    let message: String?
    let success: Bool
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 비밀번호 재설정 확인
struct PasswordResetConfirmRequest: Encodable {
    let email: String
    let code: String
    let newPassword: String
}

struct PasswordResetConfirmResponse: Decodable {
    let message: String?
    let success: Bool
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 닉네임 변경
struct ChangeNicknameRequest: Encodable {
    let nickname: String
}

struct ChangeNicknameResponse: Decodable {
    let message: String
    let success: Bool?
    let nickname: String?
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 이메일 인증 요청
struct EmailVerificationRequest: Encodable {
    let email: String
}

struct EmailVerificationResponse: Decodable {
    let message: String
    let success: Bool?
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 이메일 인증 확인
struct EmailVerificationConfirmRequest: Encodable {
    let email: String
    let verificationCode: String
}

struct EmailVerificationConfirmResponse: Decodable {
    let message: String
    let success: Bool?
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
