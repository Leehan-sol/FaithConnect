//
//  HomeView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedPrayer: Prayer? = nil
    @State private var showPrayerDetail: Bool = false
    @State private var showPrayerEditor: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.categories) { category in
                            CategoryButtonView(
                                category: category,
                                isSelected: category.id == viewModel.selectedCategoryId,
                                action: {
                                    Task {
                                        await viewModel.selectCategory(categoryID:category.id)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 0))
                
                if viewModel.prayers.isEmpty {
                    PrayerEmptyView(prayerContextType: .prayer)
                } else {
                    List {
                        ForEach(viewModel.prayers) { prayer in
                            PrayerRowView(prayer: prayer,
                                          cellType: .others)
                            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                selectedPrayer = prayer
                                showPrayerDetail = true
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refreshPrayers()
                    }
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)
                }
                
            }
            FloatingButton(action: {
                showPrayerEditor = true
            })
            
            if !viewModel.isRefreshing
                && viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(uiColor: .secondaryLabel)))
                    .scaleEffect(1.5)
            }
        }
        .navigationTitle("기도 모음")
        .navigationDestination(isPresented: $showPrayerDetail) {
            if let prayer = selectedPrayer {
                PrayerDetailView(viewModel: { viewModel.makePrayerDetailVM(prayer: prayer) })
            }
        }
        .navigationDestination(isPresented: $showPrayerEditor) {
            PrayerEditorView(
                viewModel: { viewModel.makePrayerEditorVM() })
        }
        .task {
            await viewModel.initializeIfNeeded()
        }
    }
}


#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUsecase = PrayerUseCase(repository: mockRepo)
    return HomeView(viewModel: HomeViewModel(prayerUseCase: mockUsecase))
}
