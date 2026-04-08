//
//  UserSession.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/21.
//

import Foundation

@MainActor
class UserSession: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn: Bool = false
    
    var name: String {
        user?.name ?? ""
    }

    var nickname: String {
        user?.nickname ?? ""
    }

    var email: String {
        user?.email ?? ""
    }
    
    func login(user: User) {
        self.user = user
        self.isLoggedIn = true
    }
    
    func updateNickname(_ nickname: String) {
        guard let user = user else { return }
        self.user = User(name: user.name, nickname: nickname, email: user.email)
    }

    func logout() {
        self.user = nil
        self.isLoggedIn = false
    }
    
}
