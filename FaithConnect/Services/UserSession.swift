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
    @Published var prayerCategories: [PrayerCategory] = []
    
    var churchID: Int {
        user?.id ?? 0
    }
    
    var name: String {
        user?.name ?? ""
    }
    
    var email: String {
        user?.email ?? ""
    }
    
    func login(user: User, categories: [PrayerCategory]) {
        self.user = user
        self.isLoggedIn = true
        self.prayerCategories = categories
    }
    
    func logout() {
        self.user = nil
        self.isLoggedIn = false
        self.prayerCategories = []
    }
}
