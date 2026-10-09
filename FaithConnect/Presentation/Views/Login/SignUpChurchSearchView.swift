//
//  SignUpChurchSearchView.swift
//  FaithConnect
//

import SwiftUI

struct SignUpChurchSearchView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var query = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("교회를 검색해 선택해주세요")
                    .font(.headline)
                Text("소속 교회를 선택하면 해당 교회의 기도 공동체에 참여할 수 있습니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("교회명 검색", text: $query)
                    .autocapitalization(.none)
                    .onChange(of: query) { _ in
                        viewModel.searchChurches(query: query)
                    }
                if viewModel.isSearchingChurches {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)

            List(viewModel.churchSearchResults) { church in
                NavigationLink {
                    if church.isManna {
                        CommunitySelectionView(church: church, viewModel: viewModel)
                    } else {
                        SignUpFormView(church: church, community: nil, viewModel: viewModel)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(church.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(church.roadAddress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .overlay {
                if query.isEmpty {
                    Text("교회명을 입력하면 결과가 표시됩니다.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else if viewModel.churchSearchResults.isEmpty && !viewModel.isSearchingChurches {
                    Text("검색 결과가 없습니다.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
        .scrollDismissesKeyboard(.interactively)
    }
}
