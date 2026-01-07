//
//  TokenStorage.swift
//  FaithConnect
//
//  Created by Apple on 1/5/26.
//

import Foundation

// MARK: - TokenStorageProtocol
protocol TokenStorageProtocol {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    
    func saveToken(accessToken: String, refreshToken: String)
    func clearToken()
}

// MARK: - TokenStorage
class TokenStorage: TokenStorageProtocol {
    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    var accessToken: String? {
        UserDefaults.standard.string(forKey: Key.accessToken)
    }

    var refreshToken: String? {
        UserDefaults.standard.string(forKey: Key.refreshToken)
    }

    func saveToken(accessToken: String, refreshToken: String) {
        print("accessToken: \(accessToken), refreshToken: \(refreshToken)")
        UserDefaults.standard.set(accessToken, forKey: Key.accessToken)
        UserDefaults.standard.set(refreshToken, forKey: Key.refreshToken)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
        UserDefaults.standard.removeObject(forKey: Key.refreshToken)
    }
}
