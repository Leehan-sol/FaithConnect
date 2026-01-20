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
    
    private let tokenStorage: TokenStorageProtocol
    private let apiClient: APIClientProtocol
    
    init() {
        let tokenStorage = TokenStorage()
        self.tokenStorage = tokenStorage
        self.apiClient = APIClient(tokenStorage: tokenStorage)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(apiClient: apiClient)
                .environmentObject(session)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: UserSession
    let apiClient: APIClientProtocol
    
    @State private var isCheckingAuth = true
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    var body: some View {
        Group {
            if isCheckingAuth {
                SplashView()
            } else if session.isLoggedIn {
                MainTabView(apiClient)
            } else {
                LoginView(viewModel: LoginViewModel(apiClient,
                                                    session))
            }
        }
        .onAppear {
            checkLoginStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: .logoutRequired)) { _ in
            session.logout()
        }
    }
    
    private func checkLoginStatus() {
        Task {
            guard apiClient.hasToken else {
                print("❌ 토큰 없음")
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isCheckingAuth = false
                    }
                }
                return
            }
            do {
                async let userFetch = apiClient.fetchMyInfo()
                async let categoriesFetch = try? await apiClient.loadCategories()
                
                let (user, categories) = try await (userFetch, categoriesFetch)
                
                await MainActor.run {
                    session.login(user: user, categories: categories ?? [])
                }
            } catch {
                print("❌ 토큰 만료: \(error.localizedDescription)")
            }
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isCheckingAuth = false
                }
            }
        }
    }
}

