//
//  AuthUseCase.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/13.
//

import Foundation

protocol AuthUseCaseProtocol {
    var hasToken: Bool { get }
    func signUp(name: String, email: String, password: String, confirmPassword: String) async throws
    func requestEmailVerification(email: String) async throws
    func confirmEmailVerification(email: String, verificationCode: String) async throws
    func login(email: String, password: String) async throws
    func logout() async throws
    func fetchMyInfo() async throws -> User
    func findID(name: String) async throws -> String
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

class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    var hasToken: Bool {
        repository.hasToken
    }

    func signUp(name: String, email: String, password: String, confirmPassword: String) async throws {
        try await repository.signUp(name: name,
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword)
    }

    func requestEmailVerification(email: String) async throws {
        try await repository.requestEmailVerification(email: email)
    }

    func confirmEmailVerification(email: String, verificationCode: String) async throws {
        try await repository.confirmEmailVerification(email: email, verificationCode: verificationCode)
    }

    func login(email: String, password: String) async throws {
        try await repository.login(email: email, 
                                   password: password)
    }

    func logout() async throws {
        try await repository.logout()
    }

    func fetchMyInfo() async throws -> User {
        let response = try await repository.fetchMyInfo()
        // TODO: 서버에서 name/nickname 분리 후 각각 매핑
        return User(name: response.name, nickname: response.name, email: response.email)
    }

    func findID(name: String) async throws -> String {
        try await repository.findID(name: name)
    }

    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws {
        try await repository.changePassword(id: id,
                                            name: name,
                                            email: email,
                                            newPassword: newPassword)
    }

    func changeNickname(nickname: String) async throws -> String {
        try await repository.changeNickname(nickname: nickname)
    }

    func deleteAccount() async throws {
        try await repository.deleteAccount()
    }

    func requestPasswordReset(email: String) async throws {
        try await repository.requestPasswordReset(email: email)
    }

    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        try await repository.confirmPasswordReset(email: email,
                                                  code: code,
                                                  newPassword: newPassword)
    }

    func registerPushToken(deviceToken: String) async throws {
        try await repository.registerPushToken(deviceToken: deviceToken)
    }

    func deletePushToken(deviceToken: String) async throws {
        try await repository.deletePushToken(deviceToken: deviceToken)
    }

    func testPush(title: String, body: String, data: [String: String]? = nil) async throws {
        try await repository.testPush(title: title, body: body, data: data)
    }

    func sendInquiry(title: String, content: String, userEmail: String) async throws {
        try await repository.sendInquiry(title: title, content: content, userEmail: userEmail)
    }
}
