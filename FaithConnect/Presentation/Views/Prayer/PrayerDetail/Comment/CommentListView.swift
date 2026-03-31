//
//  CommentListView.swift
//  FaithConnect
//
//  Created by Apple on 3/25/26.
//

import SwiftUI

struct CommentListView: View {
    @ObservedObject var viewModel: PrayerDetailViewModel
    @Binding var prayerBottomSheetType: PrayerBottomSheetType?
    var isReplyFocused: FocusState<Bool>.Binding
    var proxy: ScrollViewProxy?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.prayer?.responses ?? []) { response in
                VStack(spacing: 0) {
                    CommentRowView(response: response,
                                          onEdit: { response in
                        prayerBottomSheetType = .edit(response)
                    },
                                          onDelete: { response in
                        Task {
                            await viewModel.deletePrayerResponse(response: response)
                        }
                    },
                                          onReport: { response, reasonType, reasonDetail in
                        await viewModel.reportPrayerResponse(prayerResponseId: response.id,
                                                             reasonType: reasonType,
                                                             reasonDetail: reasonDetail)
                    },
                                          onBlock: { response in
                        Task { await viewModel.blockUser(userId: response.userId) }
                    },
                                          onReply: { response in
                        viewModel.startReply(to: response)
                        isReplyFocused.wrappedValue = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy?.scrollTo("replyInput-\(response.id)", anchor: .bottom)
                            }
                        }
                    })
                    .padding(EdgeInsets(top: 10,
                                        leading: 20,
                                        bottom: 10,
                                        trailing: 20))

                    // 대댓글 목록
                    if !response.replies.isEmpty {
                        VStack(spacing: 6) {
                            ForEach(response.replies) { reply in
                                // 대댓글 수정 중
                                if viewModel.editingReply?.id == reply.id {
                                    ReplyInputBar(
                                        replyText: $viewModel.replyText,
                                        isReplyFocused: isReplyFocused,
                                        isEditing: true,
                                        onSend: {
                                            Task {
                                                if let editedId = await viewModel.sendEditedReply() {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        withAnimation {
                                                            proxy?.scrollTo(editedId, anchor: .bottom)
                                                        }
                                                    }
                                                }
                                            }
                                        },
                                        onCancel: { viewModel.cancelReply() }
                                    )
                                } else {
                                    // 작성되어있는 대댓글
                                    ReplyRowView(reply: reply,
                                                 onEdit: { reply in
                                        viewModel.startEditReply(reply, in: response)
                                        isReplyFocused.wrappedValue = true
                                    },
                                                 onDelete: { reply in
                                        Task {
                                            await viewModel.deleteReply(reply, from: response)
                                        }
                                    },
                                                 onReport: { reply, reasonType, reasonDetail in
                                        await viewModel.reportPrayerResponse(prayerResponseId: reply.id,
                                                                             reasonType: reasonType,
                                                                             reasonDetail: reasonDetail)
                                    },
                                                 onBlock: { reply in
                                        Task { await viewModel.blockUser(userId: reply.userId) }
                                    })
                                    .id(reply.id)
                                    .onAppear {
                                        if reply.id == response.replies.last?.id,
                                           viewModel.isReplyExpanded(for: response.id),
                                           viewModel.hasMoreReplies(for: response.id) {
                                            Task { await viewModel.loadReplies(for: response.id) }
                                        }
                                    }
                                }
                            }

                            // 답글 더보기 버튼 (1페이지 로드 후, 더보기 누르기 전)
                            if viewModel.hasMoreReplies(for: response.id),
                               !viewModel.isReplyExpanded(for: response.id) {
                                Button {
                                    Task { await viewModel.expandReplies(for: response.id) }
                                } label: {
                                    Text("답글 더보기")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.customBlue1)
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 0,
                                            leading: 20,
                                            bottom: 10,
                                            trailing: 20))
                    }

                    // 대댓글 존재하지 않는 경우, 대댓글 작성중
                    if viewModel.replyingTo?.id == response.id, viewModel.editingReply == nil {
                        ReplyInputBar(
                            replyText: $viewModel.replyText,
                            isReplyFocused: isReplyFocused,
                            onSend: {
                                Task {
                                    if let lastReplyId = await viewModel.sendReply() {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation {
                                                proxy?.scrollTo(lastReplyId, anchor: .bottom)
                                            }
                                        }
                                    }
                                }
                            },
                            onCancel: { viewModel.cancelReply() }
                        )
                        .id("replyInput-\(response.id)")
                        .padding(EdgeInsets(top: 0,
                                            leading: 20,
                                            bottom: 10,
                                            trailing: 20))
                    }
                }
            }
        }
    }
}
