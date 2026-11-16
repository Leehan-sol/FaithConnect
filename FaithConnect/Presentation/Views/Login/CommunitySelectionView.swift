//
//  CommunitySelectionView.swift
//  FaithConnect
//

import SwiftUI

struct CommunitySelectionView: View {
    let church: Church
    @ObservedObject var viewModel: LoginViewModel
    @State private var selected: CommunityItem?
    @State private var goForm = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("소속 공동체를 선택해주세요")
                    .font(.headline)
                    .foregroundColor(Color(.darkGray))
                Text("\(church.name) · \(church.roadAddress)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))

            if viewModel.communities.isEmpty {
                if viewModel.communitiesLoadFailed {
                    VStack(spacing: 12) {
                        Text("공동체 목록을 불러오지 못했습니다")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("다시 시도") {
                            Task { await viewModel.loadCommunities() }
                        }
                    }
                    .padding(.top, 40)
                } else {
                    ProgressView()
                        .padding(.top, 40)
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.communities) { community in
                        Button {
                            selected = community
                            goForm = true
                        } label: {
                            VStack(spacing: 8) {
                                Text(community.displayName)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 22)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .task {
            if viewModel.communities.isEmpty {
                await viewModel.loadCommunities()
            }
        }
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
        .navigationDestination(isPresented: $goForm) {
            if let selected = selected {
                SignUpFormView(church: church, community: selected, viewModel: viewModel)
            }
        }
    }
}
