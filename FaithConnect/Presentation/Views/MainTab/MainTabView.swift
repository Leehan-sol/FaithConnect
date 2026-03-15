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
    private let apiClient: APIClientProtocol

    init(homeViewModel: HomeViewModel,
         myPrayerViewModel: MyPrayerViewModel,
         myPageViewModel: MyPageViewModel,
         apiClient: APIClientProtocol) {
        _homeViewModel = StateObject(wrappedValue: homeViewModel)
        _myPrayerViewModel = StateObject(wrappedValue: myPrayerViewModel)
        _myPageViewModel = StateObject(wrappedValue: myPageViewModel)
        self.apiClient = apiClient
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: homeViewModel)
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
                MyPageView(viewModel: myPageViewModel, apiClient: apiClient)
            }
            .tabItem {
                Image(systemName: "person")
                Text("마이페이지")
            }
            .tag(2)
        }
        .accentColor(.customBlue1)
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
                                         userSession: UserSession()),
        apiClient: mockAPIClient
    )
}
