//
//  ReplyRowView.swift
//  FaithConnect
//

import SwiftUI

struct ReplyRowView: View {
    @State private var showConfirmationDialog = false
    @State private var showDeleteAlert = false
    @State private var showReportAlert = false
    @State private var showBlockAlert = false
    
    let reply: PrayerResponse
    let onEdit: ((PrayerResponse) -> Void)?
    let onDelete: ((PrayerResponse) -> Void)?
    let onReport: ((PrayerResponse) -> Void)?
    let onBlock: ((PrayerResponse) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.turn.down.right")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 10) {
                Text(reply.message.trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(reply.createdAt.toTimeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Button {
                showConfirmationDialog = true
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .confirmationDialog(
            "",
            isPresented: $showConfirmationDialog,
            titleVisibility: .hidden
        ) {
            if reply.isMine == true {
                Button("수정") {
                    onEdit?(reply)
                }
                Button("삭제", role: .destructive) {
                    showDeleteAlert = true
                }
            } else {
                Button("신고", role: .destructive) {
                    showReportAlert = true
                }
                Button("차단", role: .destructive) {
                    showBlockAlert = true
                }
            }
            Button("취소", role: .cancel) { }
        }
        .alert("답글 삭제",
               isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                onDelete?(reply)
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 답글을 삭제하시겠습니까? \n삭제된 내용은 복구할 수 없습니다.")
        }
        .alert("신고",
               isPresented: $showReportAlert) {
            Button("신고", role: .destructive) {
                onReport?(reply)
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 답글을 신고하시겠습니까?")
        }
        .alert("차단",
               isPresented: $showBlockAlert) {
            Button("차단", role: .destructive) {
                onBlock?(reply)
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 사용자를 차단하시겠습니까? \n차단된 사용자의 글은 더 이상 표시되지 않습니다.")
        }
    }
}


// MARK: - ReplyInputBar
struct ReplyInputBar: View {
    @Binding var replyText: String
    var isReplyFocused: FocusState<Bool>.Binding
    var isEditing: Bool = false
    let onSend: () -> Void
    let onCancel: () -> Void

    private var isSendActive: Bool {
        !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $replyText)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .focused(isReplyFocused)

                if replyText.isEmpty {
                    Text("답글을 입력하세요...")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                        .allowsHitTesting(false)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 4, trailing: 10))

            HStack(spacing: 10) {
                Button {
                    onCancel()
                } label: {
                    Text("취소")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }

                Button {
                    onSend()
                } label: {
                    Text(isEditing ? "수정" : "전송")
                        .font(.subheadline)
                        .foregroundColor(isSendActive ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isSendActive ? Color.customBlue1 : Color(.systemGray5))
                        .cornerRadius(8)
                }
                .disabled(!isSendActive)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    ReplyRowView(reply: PrayerResponse(id: 1,
                                       prayerRequestId: 0,
                                       message: "감사합니다. 함께 기도해주셔서 힘이 됩니다.",
                                       createdAt: "2025-11-07T12:55:00.000Z",
                                       isMine: false),
                 onEdit: nil,
                 onDelete: nil,
                 onReport: nil,
                 onBlock: nil)
    .padding(.horizontal, 40)
    .padding(.vertical, 10)
}
