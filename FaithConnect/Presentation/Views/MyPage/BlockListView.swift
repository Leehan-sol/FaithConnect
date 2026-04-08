//
//  BlockListView.swift
//  FaithConnect
//

import SwiftUI

struct BlockListView: View {
    @StateObject private var viewModel: BlockListViewModel
    @State private var unblockTarget: BlockedUser? = nil

    init(viewModel: @escaping () -> BlockListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            if viewModel.blockedUsers.isEmpty && !viewModel.isLoading {
                VStack {
                    Spacer()
                    Text("차단한 사용자가 없습니다.")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.blockedUsers) { user in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.userName)
                                    .font(.body)

                                Text(user.createdAt.toTimeAgoDisplay())
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button {
                                unblockTarget = user
                            } label: {
                                Text("해제")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.customBlue1)
                                    .cornerRadius(8)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .onAppear {
                            if user.id == viewModel.blockedUsers.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("차단 관리")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
        .task {
            await viewModel.loadInitial()
        }
        .alert("차단 해제",
               isPresented: Binding(get: { unblockTarget != nil },
                                    set: { if !$0 { unblockTarget = nil } })) {
            Button("해제", role: .destructive) {
                if let user = unblockTarget {
                    Task { await viewModel.unblock(user: user) }
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("\(unblockTarget?.userName ?? "")님의 차단을 해제하시겠습니까?")
        }
        .alert(item: $viewModel.alertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")))
        }
    }
}
