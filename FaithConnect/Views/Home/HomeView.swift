//
//  HomeView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var selectedCategoryId: Int = 0
    @State private var selectedPrayer: Prayer? = nil
    @State private var showPrayerDetail: Bool = false
    @State private var showPrayerEditor: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.categories) { category in
                                CategoryButtonView(
                                    category: category,
                                    isSelected: category.id == selectedCategoryId,
                                    action: {
                                        selectedCategoryId = category.id
                                    }
                                )
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 0))
                    
                    List(viewModel.prayers) { prayer in
                        PrayerRowView(prayer: prayer, cellType: .others)
                            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                print("Tapped: \(prayer.id), \(prayer.title)")
                                selectedPrayer = prayer
                                showPrayerDetail = true
                            }
                    }
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)
                }
                
                FloatingButton(action: {
                    showPrayerEditor = true
                })
            }
            .navigationTitle("기도 모음")
            .navigationDestination(isPresented: $showPrayerDetail) {
                if let prayer = selectedPrayer {
                    PrayerDetailView(viewModel: PrayerDetailViewModel(prayer: prayer))
                }
            }
            .navigationDestination(isPresented: $showPrayerEditor) {
                PrayerEditorView(viewModel: PrayerEditorViewModel())
            }
        }.onAppear {
            Task {
                await viewModel.loadCategories()
                print(viewModel.categories)
                if let firstCategory = viewModel.categories.first {
                    selectedCategoryId = firstCategory.id
//                    await viewModel.loadPrayers(for: firstCategory.id)
                }
            }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(APIService()))
}
