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
    @Published var accessToken: String = ""
    @Published var refreshToken: String = ""
    
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
        self.accessToken = user.accessToken
        self.refreshToken = user.refreshToken
        self.isLoggedIn = true
        self.prayerCategories = categories
        UserDefaults.standard.set(user.accessToken, forKey: Constants.accessToken)
        UserDefaults.standard.set(user.refreshToken, forKey: Constants.refreshToken)
    }
    
    func logout() {
        self.user = nil
        self.isLoggedIn = false
        self.prayerCategories = []
        self.accessToken = ""
        self.refreshToken = ""
        UserDefaults.standard.removeObject(forKey: Constants.accessToken)
        UserDefaults.standard.removeObject(forKey: Constants.refreshToken)
    }
}
