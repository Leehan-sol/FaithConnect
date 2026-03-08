//
//  FaithConnectApp.swift
//  FaithConnect
//
//  Created by hansol on 2025/10/12.
//

import SwiftUI
import UserNotifications

@main
struct FaithConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var session = UserSession()

    private let tokenStorage: TokenStorageProtocol
    private let apiClient: APIClientProtocol
    private let authRepository: AuthRepositoryProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let prayerRepository: PrayerRepositoryProtocol
    private let prayerUseCase: PrayerUseCaseProtocol

    init() {
        self.tokenStorage = TokenStorage()
        self.apiClient = APIClient(tokenStorage: tokenStorage)
        self.authRepository = AuthRepository(apiClient: apiClient)
        self.authUseCase = AuthUseCase(repository: authRepository)
        self.prayerRepository = PrayerRepository(apiClient: apiClient)
        self.prayerUseCase = PrayerUseCase(repository: prayerRepository)
    }

    var body: some Scene {
        WindowGroup {
            RootView(session: session,
                     authUseCase: authUseCase,
                     prayerUseCase: prayerUseCase)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
    }
}


// MARK: - RootView
struct RootView: View {
    @ObservedObject var session: UserSession
    let authUseCase: AuthUseCaseProtocol
    let prayerUseCase: PrayerUseCaseProtocol

    @State private var isCheckingAuth = true

    init(session: UserSession,
         authUseCase: AuthUseCaseProtocol,
         prayerUseCase: PrayerUseCaseProtocol) {
        self.session = session
        self.authUseCase = authUseCase
        self.prayerUseCase = prayerUseCase
    }

    var body: some View {
        Group {
            if isCheckingAuth {
                SplashView()
            } else if session.isLoggedIn {
                MainTabView(
                    homeViewModel: HomeViewModel(prayerUseCase: prayerUseCase),
                    myPrayerViewModel: MyPrayerViewModel(prayerUseCase: prayerUseCase),
                    myPageViewModel: MyPageViewModel(authUseCase: authUseCase,
                                                    userSession: session)
                )
            } else {
                LoginView(viewModel: LoginViewModel(authUseCase: authUseCase,
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
            guard authUseCase.hasToken else {
                print("refresh 토큰 없음")
                await MainActor.run {
                    isCheckingAuth = false
                }
                return
            }

            do {
                let user = try await authUseCase.fetchMyInfo()

                await MainActor.run {
                    session.login(user: user)
                }
                print("refresh 토큰 존재")

                // 자동 로그인 시 푸시 토큰 등록
                if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                    do {
                        try await authUseCase.registerPushToken(deviceToken: fcmToken)
                        print("푸시 토큰 등록 완료")
                    } catch {
                        print("푸시 토큰 등록 실패: \(error)")
                    }
                }
            } catch {
                print("refresh 토큰 만료: \(error.localizedDescription)")
            }

            await MainActor.run {
                isCheckingAuth = false
            }
        }
    }
}
