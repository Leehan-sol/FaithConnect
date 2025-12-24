//
//  FaithConnectApp.swift
//  FaithConnect
//
//  Created by hansol on 2025/10/12.
//

import SwiftUI

@main
struct FaithConnectApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var session = UserSession()
    private let apiService: APIServiceProtocol = APIService()
    
    var body: some Scene {
        WindowGroup {
            RootView(apiService: apiService)
                .environmentObject(session)
        }
        //        .onChange(of: scenePhase) { oldValue, newPhase in
        //            if newPhase == .active {
        //
        //            } else if newPhase == .background {
        //                isLoggedIn = false
        //            }
        //        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: UserSession
    let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    var body: some View {
        if session.isLoggedIn {
            MainTabView(apiService: apiService)
        } else {
            LoginView(viewModel: LoginViewModel(apiService, session))
        }
    }
}
