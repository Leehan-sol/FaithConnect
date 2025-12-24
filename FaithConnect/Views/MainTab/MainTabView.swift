//
//  MainTabView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct MainTabView: View {
    let apiService: APIServiceProtocol
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var myPrayerViewModel: MyPrayerViewModel
    @StateObject private var myPageViewModel: MyPageViewModel
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(apiService))
        _myPrayerViewModel = StateObject(wrappedValue: MyPrayerViewModel(apiService))
        _myPageViewModel = StateObject(wrappedValue: MyPageViewModel(apiService))
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
                MyPageView(viewModel: myPageViewModel)
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
    MainTabView(apiService: APIService())
}
