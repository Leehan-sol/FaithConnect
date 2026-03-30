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
                        await viewModel.reportPrayerResponse(prayerResponseId: response.id, reasonType: reasonType, reasonDetail: reasonDetail)
                    },
                                          onBlock: { _ in
                        // TODO: - 차단
                        viewModel.blockWriter()
                    },
                                          onReply: { response in
                        viewModel.startReply(to: response)
                        isReplyFocused.wrappedValue = true // 키보드 올리기
                    })
                    .padding(EdgeInsets(top: 10,
                                        leading: 20,
                                        bottom: 10,
                                        trailing: 20))

                    // 대댓글 존재하는 경우
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
                                            if let editedId = viewModel.sendEditedReply() {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation {
                                                        proxy?.scrollTo(editedId, anchor: .bottom)
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

                                    },
                                                 onReport: { reply, reasonType, reasonDetail in
                                        await viewModel.reportPrayerResponse(prayerResponseId: reply.id, reasonType: reasonType, reasonDetail: reasonDetail)
                                    },
                                                 onBlock: { _ in
                                        viewModel.blockWriter()
                                    })
                                    .id(reply.id)
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 0,
                                            leading: 40,
                                            bottom: 10,
                                            trailing: 20))
                    }

                    // 대댓글 존재하지 않는 경우, 대댓글 작성중
                    if viewModel.replyingTo?.id == response.id, viewModel.editingReply == nil {
                        ReplyInputBar(
                            replyText: $viewModel.replyText,
                            isReplyFocused: isReplyFocused,
                            onSend: {
                                if let lastReplyId = viewModel.sendReply() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            proxy?.scrollTo(lastReplyId, anchor: .bottom)
                                        }
                                    }
                                }
                            },
                            onCancel: { viewModel.cancelReply() }
                        )
                        .padding(EdgeInsets(top: 0,
                                            leading: 40,
                                            bottom: 10,
                                            trailing: 20))
                    }
                }
            }
        }
    }
}
