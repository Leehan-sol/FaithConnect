//
//  AuthRepositoryProtocol.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/13.
//

import Foundation

protocol AuthRepositoryProtocol {
    var hasToken: Bool { get }
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws
    func login(email: String, password: String) async throws
    func logout() async throws
    func fetchMyInfo() async throws -> FetchMyInfoResponse
    func findID(memberID: Int, name: String) async throws -> String
    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws
    func deleteAccount() async throws
    func registerPushToken(deviceToken: String) async throws
    func deletePushToken(deviceToken: String) async throws
}

