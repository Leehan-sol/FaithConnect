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
    private let tokenStorage = TokenStorage()
    private let apiClient: APIClientProtocol
    
    init() {
        self.apiClient = APIClient(tokenStorage: tokenStorage)
    }
 
    var body: some Scene {
        WindowGroup {
            RootView(apiClient: apiClient)
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
    let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    var body: some View {
        if session.isLoggedIn {
            MainTabView(apiClient)
        } else {
            LoginView(viewModel: LoginViewModel(apiClient, session))
        }
    }
}
