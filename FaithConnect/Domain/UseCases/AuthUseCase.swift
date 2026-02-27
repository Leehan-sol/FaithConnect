//
//  AuthUseCase.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/13.
//

import Foundation

protocol AuthUseCaseProtocol {
    var hasToken: Bool { get }
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws
    func login(email: String, password: String) async throws
    func logout() async throws
    func fetchMyInfo() async throws -> User
    func findID(memberID: Int, name: String) async throws -> String
    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws
    func deleteAccount() async throws
    func registerPushToken(deviceToken: String) async throws
    func deletePushToken(deviceToken: String) async throws
}

class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    var hasToken: Bool {
        repository.hasToken
    }

    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws {
        try await repository.signUp(memberID: memberID, 
                                    name: name,
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword)
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
        return User(name: response.name, email: response.email)
    }

    func findID(memberID: Int, name: String) async throws -> String {
        try await repository.findID(memberID: memberID, 
                                    name: name)
    }

    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws {
        try await repository.changePassword(id: id,
                                            name: name,
                                            email: email,
                                            newPassword: newPassword)
    }

    func deleteAccount() async throws {
        try await repository.deleteAccount()
    }

    func registerPushToken(deviceToken: String) async throws {
        try await repository.registerPushToken(deviceToken: deviceToken)
    }

    func deletePushToken(deviceToken: String) async throws {
        try await repository.deletePushToken(deviceToken: deviceToken)
    }
}
