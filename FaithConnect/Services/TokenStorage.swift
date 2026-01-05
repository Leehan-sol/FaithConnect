//
//  TokenStorage.swift
//  FaithConnect
//
//  Created by Apple on 1/5/26.
//

import Foundation

protocol TokenStorageProtocol {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    
    func save(accessToken: String, refreshToken: String)
    func updateAccessToken(accessToken: String)
    func clear()
}

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

    func save(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Key.accessToken)
        UserDefaults.standard.set(refreshToken, forKey: Key.refreshToken)
    }

    func updateAccessToken(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Key.accessToken)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
        UserDefaults.standard.removeObject(forKey: Key.refreshToken)
    }
}
