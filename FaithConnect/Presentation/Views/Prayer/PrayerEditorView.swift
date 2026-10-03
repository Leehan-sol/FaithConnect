//
//  PrayerEditorView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct PrayerEditorView: View {
    @StateObject var viewModel: PrayerEditorViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategoryId: Int = 0
    @State var title: String = ""
    @State var content: String = ""
    @State var showAlert: Bool = false

    init(viewModel: @escaping () -> PrayerEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Spacer()
                .frame(height: 20)

            VStack(alignment: .leading, spacing: 10) {
                if viewModel.isManna {
                    communitySelector
                } else {
                    categorySelector
                }

                LabeledTextField(title: "제목", placeholder: "기도 제목을 입력하세요", text: $title)
                    .padding(.bottom, 20)

                Text("내용")
                    .font(.subheadline)
                    .bold()

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .frame(height: 250)
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .scrollContentBackground(.hidden)
                        .onChange(of: content) { newValue in
                            if newValue.count > 2000 {
                                content = String(newValue.prefix(2000))
                            }
                        }

                    if content.isEmpty {
                        Text("기도 내용을 입력하세요")
                            .foregroundColor(Color(uiColor: .placeholderText))
                            .font(.body)
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                            .allowsHitTesting(false)
                    }
                }
                .padding(.bottom, 20)

                if viewModel.isManna {
                    visibilitySettings
                }

                InfoBoxView(messages: [
                    "• 기도제목은 익명으로 공유됩니다.",
                    "• 이름과 연락처 등 개인정보는 작성하지 말아주세요.",
                    "• 모든 성도들이 함께 기도할 수 있도록 진솔하게 작성해 주세요."])

                Spacer()

            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            .navigationTitle(viewModel.isEditMode ? "기도 수정" : "새 기도")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                            .bold()
                            .foregroundColor(.black)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.savePrayer(
                                categoryId: viewModel.isManna ? nil : selectedCategoryId,
                                community: viewModel.isManna ? viewModel.selectedCommunity : nil,
                                visibility: viewModel.isManna ? viewModel.selectedVisibility : nil,
                                displayNameType: viewModel.isManna ? viewModel.selectedDisplayNameType : nil,
                                title: title,
                                content: content)
                            if viewModel.alertType == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("완료")
                            .bold()
                            .foregroundColor(.black)
                    }
                }
            }
            .toolbarVisibility(.hidden, for: .tabBar)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .alert(item: $viewModel.alertType) { alert in
                Alert(title: Text(alert.title),
                      message: Text(alert.message),
                      dismissButton: .default(Text("확인")))
            }
            .task {
                await viewModel.fetchCategories()
                if let prayer = viewModel.prayer {
                    selectedCategoryId = prayer.categoryId ?? 0
                    title = prayer.title
                    content = prayer.content
                    if let c = prayer.community, let community = Community(rawValue: c) {
                        viewModel.selectedCommunity = community
                    }
                    if let v = prayer.visibility { viewModel.selectedVisibility = v }
                    if let d = prayer.displayNameType { viewModel.selectedDisplayNameType = d }
                }
            }
        }
    }

    // MARK: - 카테고리 선택 (DEFAULT)
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("카테고리")
                .font(.subheadline)
                .bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.categories, id: \.self) { category in
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
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
        }
    }

    // MARK: - 공동체 선택 (MANNA)
    private var communitySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("공동체")
                .font(.subheadline)
                .bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Community.allCases) { community in
                        let isSelected = viewModel.selectedCommunity == community
                        Button {
                            viewModel.selectedCommunity = community
                        } label: {
                            Text(community.displayName)
                                .font(.subheadline)
                                .fontWeight(isSelected ? .bold : .regular)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.customBlue1 : Color(.systemGray6))
                                .foregroundColor(isSelected ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - 공개 설정 (MANNA)
    private var visibilitySettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("공개 설정")
                .font(.subheadline)
                .bold()

            VStack(spacing: 0) {
                HStack {
                    Text("공개범위")
                        .font(.subheadline)
                    Spacer()
                    Picker("", selection: $viewModel.selectedVisibility) {
                        ForEach(Visibility.allCases) { v in
                            Text(v.displayName).tag(v)
                        }
                    }
                    .tint(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()
                    .padding(.leading, 16)

                HStack {
                    Text("표시이름")
                        .font(.subheadline)
                    Spacer()
                    Picker("", selection: $viewModel.selectedDisplayNameType) {
                        ForEach(DisplayNameType.allCases, id: \.self) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    .tint(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepo = PrayerRepository(apiClient: mockAPIClient)
    let mockUseCase = PrayerUseCase(repository: mockRepo)

    return NavigationStack {
        PrayerEditorView(viewModel: { PrayerEditorViewModel(prayerUseCase: mockUseCase, isManna: true, userCommunity: .joseph) })
    }
}
