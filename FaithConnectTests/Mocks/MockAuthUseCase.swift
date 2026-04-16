//
//  MockAuthUseCase.swift
//  FaithConnectTests
//

import Foundation
@testable import FaithConnect

class MockAuthUseCase: AuthUseCaseProtocol {

    // MARK: - 스텁 설정
    var stubbedHasToken: Bool = false
    var stubbedUser: User = User(name: "", email: "")
    var stubbedFoundEmail: String = ""
    var stubbedError: Error?

    // MARK: - 호출 추적
    var loginCalledWith: (email: String, password: String)?
    var signUpCalledWith: (memberID: Int, name: String, email: String, password: String, confirmPassword: String)?
    var logoutCalled = false
    var fetchMyInfoCalled = false
    var findIDCalledWith: (memberID: Int, name: String)?
    var registerPushTokenCalledWith: String?

    // MARK: - AuthUseCaseProtocol
    var hasToken: Bool { stubbedHasToken }

    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws {
        signUpCalledWith = (memberID, name, email, password, confirmPassword)
        if let error = stubbedError { throw error }
    }

    func login(email: String, password: String) async throws {
        loginCalledWith = (email, password)
        if let error = stubbedError { throw error }
    }

    func logout() async throws {
        logoutCalled = true
        if let error = stubbedError { throw error }
    }

    func fetchMyInfo() async throws -> User {
        fetchMyInfoCalled = true
        if let error = stubbedError { throw error }
        return stubbedUser
    }

    func findID(memberID: Int, name: String) async throws -> String {
        findIDCalledWith = (memberID, name)
        if let error = stubbedError { throw error }
        return stubbedFoundEmail
    }

    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws {
        if let error = stubbedError { throw error }
    }

    func deleteAccount() async throws {
        if let error = stubbedError { throw error }
    }

    func requestPasswordReset(email: String) async throws {
        if let error = stubbedError { throw error }
    }

    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        if let error = stubbedError { throw error }
    }

    func registerPushToken(deviceToken: String) async throws {
        registerPushTokenCalledWith = deviceToken
        if let error = stubbedError { throw error }
    }

    func deletePushToken(deviceToken: String) async throws {
        if let error = stubbedError { throw error }
    }

    func testPush(title: String, body: String, data: [String: String]?) async throws {
        if let error = stubbedError { throw error }
    }

    func sendInquiry(title: String, content: String, userEmail: String) async throws {
        if let error = stubbedError { throw error }
    }
}
