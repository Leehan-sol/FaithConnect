//
//  HomeView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: UserSession
    @StateObject var viewModel: HomeViewModel
    @State private var selectedCategoryId: Int = 0
    @State private var selectedPrayer: Prayer? = nil
    @State private var showPrayerDetail: Bool = false
    @State private var showPrayerEditor: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(session.categories) { category in
                            CategoryButtonView(
                                category: category,
                                isSelected: category.id == selectedCategoryId,
                                action: {
                                    selectedCategoryId = category.id
                                    print("selectedCategoryId: \(selectedCategoryId)")
                                    Task {
                                        await viewModel.loadPrayers(categoryId: selectedCategoryId,
                                                                    reset: true)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 0))
                
                // TODO: - 로딩중 추가 구현 필요
                if viewModel.prayers.isEmpty {
                    EmptyPrayerView()
                } else {
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
                    .refreshable {
                        await viewModel.loadPrayers(categoryId: selectedCategoryId,
                                                    reset: true)
                    }
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)
                }
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
        }.onAppear {
            Task {
                if let firstCategory = session.categories.first {
                    selectedCategoryId = firstCategory.id // 첫 카테고리 선택
                    await viewModel.loadPrayers(categoryId: firstCategory.id,
                                                reset: true) // 카테고리 목록 조회
                }
            }
        }
    }
}



struct EmptyPrayerView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image(systemName: "figure.and.child.holdinghands")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
                .background(Color(.systemGray4))
                .cornerRadius(10)
                .padding(.bottom)
            
            Text("아직 기도가 없습니다")
                .font(.subheadline)
                
            Text("첫 번째 기도를 작성해보세요")
                .font(.footnote)
            
            Spacer()
        }
        .foregroundColor(Color(.darkGray))
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(APIService()))
}
