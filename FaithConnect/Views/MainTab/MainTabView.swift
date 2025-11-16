//
//  MainTabView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                let homeViewModel = HomeViewModel(APIService())
                HomeView(viewModel: homeViewModel)
            }
            .tabItem {
                VStack {
                    Image(systemName: "house")
                    Text("홈")
                }
            }
            .tag(0)
            
            NavigationStack {
                MyPrayerView()
            }
            .tabItem {
                Image(systemName: "heart.text.square.fill")
                Text("내 기도")
            }
            .tag(1)
            
            NavigationStack {
                MyPageView()
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
    MainTabView()
}
