//
//  AuthRepository.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/13.
//

import Foundation

class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    var hasToken: Bool {
        apiClient.hasToken
    }

    func signUp(name: String, nickname: String, email: String, password: String, confirmPassword: String) async throws {
        try await apiClient.signUp(name: name,
                                   nickname: nickname,
                                   email: email,
                                   password: password,
                                   confirmPassword: confirmPassword)
    }

    func requestEmailVerification(email: String) async throws {
        try await apiClient.requestEmailVerification(email: email)
    }

    func confirmEmailVerification(email: String, verificationCode: String) async throws {
        try await apiClient.confirmEmailVerification(email: email, verificationCode: verificationCode)
    }

    func login(email: String, password: String) async throws {
        try await apiClient.login(email: email, 
                                  password: password)
    }

    func logout() async throws {
        try await apiClient.logout()
    }

    func fetchMyInfo() async throws -> FetchMyInfoResponse {
        try await apiClient.fetchMyInfo()
    }

    func findID(name: String, nickname: String) async throws -> String {
        try await apiClient.findID(name: name, nickname: nickname)
    }

    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws {
        try await apiClient.changePassword(id: id,
                                           name: name,
                                           email: email,
                                           newPassword: newPassword)
    }

    func changeNickname(nickname: String) async throws -> String {
        try await apiClient.changeNickname(nickname: nickname)
    }

    func deleteAccount() async throws {
        try await apiClient.deleteAccount()
    }

    func requestPasswordReset(email: String) async throws {
        try await apiClient.requestPasswordReset(email: email)
    }

    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        try await apiClient.confirmPasswordReset(email: email,
                                                 code: code,
                                                 newPassword: newPassword)
    }

    func registerPushToken(deviceToken: String) async throws {
        try await apiClient.registerPushToken(deviceToken: deviceToken)
    }

    func deletePushToken(deviceToken: String) async throws {
        try await apiClient.deletePushToken(deviceToken: deviceToken)
    }

    func testPush(title: String, body: String, data: [String: String]? = nil) async throws {
        try await apiClient.testPush(title: title, body: body, data: data)
    }

    func sendInquiry(title: String, content: String, userEmail: String) async throws {
        try await apiClient.sendInquiry(title: title, content: content, userEmail: userEmail)
    }
}
