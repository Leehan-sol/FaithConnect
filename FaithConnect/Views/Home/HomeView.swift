//
//  HomeView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var showPrayerDetail: Bool = false
    @State private var showPrayerEditor: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(viewModel.prayers) { prayer in
                    PrayerRowView(prayer: prayer, cellType: .others)
                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            print("Tapped: \(prayer.id), \(prayer.title)")
                            showPrayerDetail = true
                        }
                }
                .listStyle(PlainListStyle())
                
                FloatingButton(action: {
                    showPrayerEditor = true
                })
            }
            .navigationTitle("기도 모음")
            .navigationDestination(isPresented: $showPrayerDetail) {
                PrayerDetailView()
             }
            .navigationDestination(isPresented: $showPrayerEditor) {
                PrayerEditorView()
             }
        }
    }
}

#Preview {
    HomeView()
}
