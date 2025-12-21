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
    
    func login(user: User) {
        self.user = user
        self.isLoggedIn = true
    }
    
    func logout() {
        self.user = nil
        self.isLoggedIn = false
    }
}
