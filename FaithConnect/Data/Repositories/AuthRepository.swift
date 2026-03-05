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

    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws {
        try await apiClient.signUp(memberID: memberID, 
                                   name: name,
                                   email: email,
                                   password: password,
                                   confirmPassword: confirmPassword)
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

    func findID(memberID: Int, name: String) async throws -> String {
        try await apiClient.findID(memberID: memberID, name: name)
    }

    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws {
        try await apiClient.changePassword(id: id,
                                           name: name,
                                           email: email,
                                           newPassword: newPassword)
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
}
