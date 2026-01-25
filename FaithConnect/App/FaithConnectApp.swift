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
    private let prayerRepository: PrayerRepositoryProtocol
    
    init() {
        self.tokenStorage = TokenStorage()
        self.apiClient = APIClient(tokenStorage: tokenStorage)
        self.prayerRepository = PrayerRepository(apiClient: apiClient)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(apiClient: apiClient,
                     prayerRepository: prayerRepository)
            .environmentObject(session)
        }
    }
}


// MARK: - RootView
struct RootView: View {
    @EnvironmentObject var session: UserSession
    let apiClient: APIClientProtocol
    let prayerRepository: PrayerRepositoryProtocol
    
    @State private var isCheckingAuth = true
    
    init(apiClient: APIClientProtocol, prayerRepository: PrayerRepositoryProtocol) {
        self.apiClient = apiClient
        self.prayerRepository = prayerRepository
    }
    
    var body: some View {
        Group {
            if isCheckingAuth {
                SplashView()
            } else if session.isLoggedIn {
                // TODO: - AuthRepository 분리 (apiClient 주입) -> ViewModel에서 APIClient를 몰라도됨
                MainTabView(
                    homeViewModel: HomeViewModel(prayerRepository: prayerRepository),
                    myPrayerViewModel: MyPrayerViewModel(prayerRepository: prayerRepository),
                    myPageViewModel: MyPageViewModel(apiClient: apiClient)
                )
            } else {
                LoginView(viewModel: LoginViewModel(apiClient: apiClient,
                                                    session: session))
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
                let user = try await apiClient.fetchMyInfo()
                
                await MainActor.run {
                    session.login(user: user)
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
