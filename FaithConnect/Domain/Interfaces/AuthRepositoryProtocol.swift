//
//  AuthRepositoryProtocol.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/13.
//

import Foundation

protocol AuthRepositoryProtocol {
    var hasToken: Bool { get }
    func signUp(name: String, nickname: String, email: String, password: String, confirmPassword: String) async throws
    func requestEmailVerification(email: String) async throws
    func confirmEmailVerification(email: String, verificationCode: String) async throws
    func login(email: String, password: String) async throws
    func logout() async throws
    func fetchMyInfo() async throws -> FetchMyInfoResponse
    func findID(name: String, nickname: String) async throws -> String
    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws
    func changeNickname(nickname: String) async throws -> String
    func deleteAccount() async throws
    func requestPasswordReset(email: String) async throws
    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws
    func registerPushToken(deviceToken: String) async throws
    func deletePushToken(deviceToken: String) async throws
    func testPush(title: String, body: String, data: [String: String]?) async throws
    func sendInquiry(title: String, content: String, userEmail: String) async throws
}

