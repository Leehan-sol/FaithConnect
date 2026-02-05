//
//  TokenStorage.swift
//  FaithConnect
//
//  Created by Apple on 1/5/26.
//

import Foundation
import Security

// MARK: - TokenStorageProtocol
protocol TokenStorageProtocol {
    var accessToken: String? { get }
    var refreshToken: String? { get }

    func save(accessToken: String, refreshToken: String)
    func clear()
}

// MARK: - TokenStorage
class TokenStorage: TokenStorageProtocol {
    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }

    private let serviceName = "FaithConnect.auth"


    var accessToken: String? {
        getFromKeychain(key: Key.accessToken)
    }

    var refreshToken: String? {
        getFromKeychain(key: Key.refreshToken)
    }

    func save(accessToken: String, refreshToken: String) {
        saveToKeychain(key: Key.accessToken, value: accessToken)
        saveToKeychain(key: Key.refreshToken, value: refreshToken)
    }

    func clear() {
        deleteFromKeychain(key: Key.accessToken)
        deleteFromKeychain(key: Key.refreshToken)
    }

    private func debugPrint(_ message: String) {
#if DEBUG
        print(message)
#endif
    }

    private func keychainQuery(for key: String) -> [String: Any] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        return query
    }

    private func saveToKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else {
            debugPrint("토큰 데이터로 변환 실패 - key: \(key)")
            return
        }

        var query = keychainQuery(for: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked

        // 기존 항목이 있으면 삭제 후 저장
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            debugPrint("토큰 저장 실패 - key: \(key), status: \(status)")
        } else {
            debugPrint("토큰 저장 성공 - key: \(key)")
        }
    }

    private func getFromKeychain(key: String) -> String? {
        var query = keychainQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            if let data = result as? Data,
               let token = String(data: data, encoding: .utf8) {
                return token
            }
        } else if status == errSecItemNotFound {
            // 항목이 없는 것은 정상적인 상태
            return nil
        } else {
            debugPrint("토큰 조회 실패 - key: \(key), status: \(status)")
        }

        return nil
    }

    private func deleteFromKeychain(key: String) {
        let query = keychainQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            debugPrint("토큰 삭제 성공 - key: \(key)")
        } else {
            debugPrint("토큰 삭제 실패 - key: \(key), status: \(status)")
        }
    }
}
