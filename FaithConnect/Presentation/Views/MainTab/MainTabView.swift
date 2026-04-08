//
//  MainTabView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var myPrayerViewModel: MyPrayerViewModel
    @StateObject private var myPageViewModel: MyPageViewModel
    @ObservedObject var deepLinkManager: DeepLinkManager

    @State private var selectedTab: Int = 0
    @State private var homeScrollToTop: Bool = false
    @State private var showDeepLinkPrayerDetail: Bool = false
    @State private var deepLinkPrayerRequestId: Int? = nil

    init(homeViewModel: HomeViewModel,
         myPrayerViewModel: MyPrayerViewModel,
         myPageViewModel: MyPageViewModel,
         deepLinkManager: DeepLinkManager) {
        _homeViewModel = StateObject(wrappedValue: homeViewModel)
        _myPrayerViewModel = StateObject(wrappedValue: myPrayerViewModel)
        _myPageViewModel = StateObject(wrappedValue: myPageViewModel)
        self.deepLinkManager = deepLinkManager
    }

    var body: some View {
        TabView(selection: tabSelection) {
            NavigationStack {
                HomeView(viewModel: homeViewModel, scrollToTop: $homeScrollToTop)
                    .navigationDestination(isPresented: $showDeepLinkPrayerDetail) {
                        if let id = deepLinkPrayerRequestId {
                            PrayerDetailView(viewModel: {
                                homeViewModel.makePrayerDetailVM(prayerRequestId: id)
                            })
                        }
                    }
            }
            .tabItem {
                Image(systemName: "house")
                Text("홈")
            }
            .tag(0)

            NavigationStack {
                MyPrayerView(viewModel: myPrayerViewModel)
            }
            .tabItem {
                Image(systemName: "heart.text.square.fill")
                Text("내 기도")
            }
            .tag(1)

            NavigationStack {
                MyPageView(viewModel: myPageViewModel)
            }
            .tabItem {
                Image(systemName: "person")
                Text("마이페이지")
            }
            .tag(2)
        }
        .accentColor(.customBlue1)
        .onChange(of: deepLinkManager.pendingDestination) { _, destination in
            if let destination {
                handleDeepLink(destination)
            }
        }
        .onAppear {
            if let destination = deepLinkManager.pendingDestination {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    handleDeepLink(destination)
                }
            }
        }
    }

    // MARK: - 탭 선택 (같은 탭 재탭 시 상단 이동)
    private var tabSelection: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { newTab in
                if newTab == selectedTab && newTab == 0 {
                    homeScrollToTop = true
                }
                selectedTab = newTab
            }
        )
    }

    // MARK: - 딥링크 처리
    private func handleDeepLink(_ destination: DeepLinkDestination) {
        switch destination {
        case .prayerDetail(let prayerRequestId):
            selectedTab = 0
            showDeepLinkPrayerDetail = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                deepLinkPrayerRequestId = prayerRequestId
                showDeepLinkPrayerDetail = true
                deepLinkManager.clearDestination()
            }
        }
    }
}

#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUseCase = PrayerUseCase(repository: mockRepo)

    return MainTabView(
        homeViewModel: HomeViewModel(prayerUseCase: mockUseCase),
        myPrayerViewModel: MyPrayerViewModel(prayerUseCase: mockUseCase),
        myPageViewModel: MyPageViewModel(authUseCase: AuthUseCase(repository: AuthRepository(apiClient: mockAPIClient)),
                                         prayerUseCase: mockUseCase,
                                         userSession: UserSession()),
        deepLinkManager: DeepLinkManager()
    )
}
