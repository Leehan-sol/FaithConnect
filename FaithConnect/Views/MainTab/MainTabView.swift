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
                HomeView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "house")
                    Text("홈")
                }
            }
            .tag(0)
            
            NavigationStack {
                MyPageView()
            }
            .tabItem {
                Image(systemName: "person")
                Text("마이페이지")
            }
            .tag(1)
        }
        .accentColor(.customBlue1)
    }
}

#Preview {
    MainTabView()
}
