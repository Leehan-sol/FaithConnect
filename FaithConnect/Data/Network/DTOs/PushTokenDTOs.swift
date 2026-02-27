//
//  PushTokenDTOs.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/27.
//

import Foundation

// MARK: - 푸시 토큰 등록
struct PushTokenRegisterRequest: Encodable {
    let deviceToken: String
    let platform: String
}

// MARK: - 푸시 토큰 삭제
struct PushTokenDeleteRequest: Encodable {
    let deviceToken: String
}

struct PushTokenResponse: Decodable {
    let message: String?
    let success: Bool?
    let errorCode: APIErrorCode?
    let status: Int?
}
