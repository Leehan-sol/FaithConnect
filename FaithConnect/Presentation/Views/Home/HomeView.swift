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
    @Binding var scrollToTop: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                if viewModel.prayers.isEmpty {
                    emptyStateView
                } else {
                    prayerListView(proxy: proxy)
                }

                FloatingButton(action: {
                    showPrayerEditor = true
                })

                if !viewModel.isRefreshing && viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(uiColor: .secondaryLabel)))
                        .scaleEffect(1.5)
                }
            }
            .onChange(of: scrollToTop) { _ in
                if scrollToTop {
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                    Task {
                        await viewModel.refreshPrayers()
                    }
                    scrollToTop = false
                }
            }
        }
        .navigationTitle("기도 모음")
        .navigationBarTitleDisplayMode(.automatic)
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
        .alert(item: $viewModel.alertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")))
        }
    }

    // MARK: - 카테고리 버튼
    private var categoryButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories) { category in
                    CategoryButtonView(
                        category: category,
                        isSelected: category.id == viewModel.selectedCategoryId,
                        action: {
                            Task {
                                await viewModel.selectCategory(categoryID: category.id)
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - 빈 상태 뷰
    private var emptyStateView: some View {
        VStack {
            categoryButtons
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 0))
            PrayerEmptyView(prayerContextType: .prayer)
        }
    }

    // MARK: - 기도 목록 뷰
    private func prayerListView(proxy: ScrollViewProxy) -> some View {
        List {
            Section {
                categoryButtons
                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .id("top")
            }

            ForEach(viewModel.prayers) { prayer in
                prayerRow(prayer: prayer)
            }
        }
        .refreshable {
            await viewModel.refreshPrayers()
        }
        .listStyle(PlainListStyle())
        .scrollIndicators(.hidden)
    }

    // MARK: - 기도 셀
    private func prayerRow(prayer: Prayer) -> some View {
        PrayerRowView(prayer: prayer, cellType: .others)
            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .onTapGesture {
                selectedPrayer = prayer
                showPrayerDetail = true
            }
            .onAppear {
                if prayer.id == viewModel.prayers.last?.id {
                    Task {
                        await viewModel.loadMorePrayers()
                    }
                }
            }
    }

}


#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUsecase = PrayerUseCase(repository: mockRepo)
    let vm = HomeViewModel(prayerUseCase: mockUsecase)

    vm.categories = [
        PrayerCategory(id: 0, categoryCode: 0, categoryName: "전체"),
        PrayerCategory(id: 1, categoryCode: 1, categoryName: "건강"),
        PrayerCategory(id: 2, categoryCode: 2, categoryName: "가정"),
        PrayerCategory(id: 3, categoryCode: 3, categoryName: "학업"),
        PrayerCategory(id: 4, categoryCode: 4, categoryName: "직장"),
        PrayerCategory(id: 5, categoryCode: 5, categoryName: "감사")
    ]

    vm.prayers = [
        Prayer(id: 1, userId: 1, userName: "", categoryId: 1, categoryName: "건강",
               title: "아버지의 건강 회복을 위해",
               content: "최근 아버지께서 수술을 받으셨습니다. 빠른 회복을 위해 기도 부탁드립니다.",
               createdAt: "2026-03-26", participationCount: 12, responses: nil, isMine: false),
        Prayer(id: 2, userId: 2, userName: "", categoryId: 2, categoryName: "가정",
               title: "가정의 평안을 위한 기도",
               content: "가족 간에 갈등이 있습니다. 서로 이해하고 사랑할 수 있도록 기도해주세요.",
               createdAt: "2026-03-25", participationCount: 8, responses: nil, isMine: false),
        Prayer(id: 3, userId: 3, userName: "", categoryId: 3, categoryName: "학업",
               title: "시험 준비를 위한 기도",
               content: "다음 주 중요한 시험이 있습니다. 집중력과 지혜를 주시길 기도합니다.",
               createdAt: "2026-03-25", participationCount: 5, responses: nil, isMine: false),
        Prayer(id: 4, userId: 4, userName: "", categoryId: 4, categoryName: "직장",
               title: "새 직장 적응을 위해",
               content: "이번 주부터 새 직장에 출근합니다. 잘 적응할 수 있도록 기도 부탁드립니다.",
               createdAt: "2026-03-24", participationCount: 15, responses: nil, isMine: true),
        Prayer(id: 5, userId: 5, userName: "", categoryId: 5, categoryName: "감사",
               title: "감사 기도",
               content: "올 한 해 건강하게 보낼 수 있어서 감사합니다. 함께 감사 기도 나눠요.",
               createdAt: "2026-03-24", participationCount: 20, responses: nil, isMine: false),
    ]

    return NavigationStack {
        HomeView(viewModel: vm, scrollToTop: .constant(false))
    }
}
