//
//  HomeView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(viewModel.prayers) { prayer in
                    PrayerRowView(prayer: prayer)
                        .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                
                FloatingButton(action: {
                    print("플로팅 버튼 클릭")
                })
            }
            .navigationTitle("기도 모음")
        }
    }
}

#Preview {
    HomeView()
}
