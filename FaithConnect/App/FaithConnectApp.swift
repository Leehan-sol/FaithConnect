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
    private let prayerUseCase: PrayerUseCaseProtocol
    
    init() {
        self.tokenStorage = TokenStorage()
        self.apiClient = APIClient(tokenStorage: tokenStorage)
        self.prayerRepository = PrayerRepository(apiClient: apiClient)
        self.prayerUseCase = PrayerUseCase(repository: prayerRepository)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(session: session,
                     apiClient: apiClient, // TODO: - 1) AuthuseCase 사용으로 변경해야함
                     prayerUseCase: prayerUseCase)
        }
    }
}


// MARK: - RootView
struct RootView: View {
    @ObservedObject var session: UserSession
    let apiClient: APIClientProtocol // TODO: - 2)
    let prayerUseCase: PrayerUseCaseProtocol
    
    @State private var isCheckingAuth = true
    
    init(session: UserSession,
         apiClient: APIClientProtocol,
         prayerUseCase: PrayerUseCaseProtocol) {
        self.session = session
        self.apiClient = apiClient
        self.prayerUseCase = prayerUseCase
    }
    
    var body: some View {
        Group {
            if isCheckingAuth {
                SplashView()
            } else if session.isLoggedIn {
                // TODO: - 3) AuthRepository 분리 (apiClient 주입) -> ViewModel에서 APIClient를 몰라도됨
                MainTabView(
                    homeViewModel: HomeViewModel(prayerUseCase: prayerUseCase),
                    myPrayerViewModel: MyPrayerViewModel(prayerUseCase: prayerUseCase),
                    myPageViewModel: MyPageViewModel(apiClient: apiClient,
                                                    userSession: session)
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
