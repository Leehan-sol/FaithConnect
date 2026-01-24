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
        self.tokenStorage = TokenStorage()
        self.apiClient = APIClient(tokenStorage: tokenStorage)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(apiClient: apiClient)
                .environmentObject(session)
        }
    }
}


// MARK: - RootView
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
                MainTabView(
                    homeViewModel: HomeViewModel(apiClient),
                    myPrayerViewModel: MyPrayerViewModel(apiClient),
                    myPageViewModel: MyPageViewModel(apiClient)
                )
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
}



// MARK: - Extension
private extension RootView {
    private func checkLoginStatus() {
        Task {
            guard apiClient.hasToken else {
                print("❌ 토큰 없음")
                await MainActor.run {
                    isCheckingAuth = false
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
                print("⭕️ 토큰 존재")
            } catch {
                print("❌ 토큰 만료: \(error.localizedDescription)")
            }
            
            await MainActor.run {
                isCheckingAuth = false
            }
        }
    }
}
