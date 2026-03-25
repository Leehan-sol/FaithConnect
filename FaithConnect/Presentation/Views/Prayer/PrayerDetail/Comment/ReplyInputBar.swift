//
//  ReplyInputBar.swift
//  FaithConnect
//
//  Created by Apple on 3/25/26.
//

import SwiftUI

struct ReplyInputBar: View {
    @Binding var replyText: String
    var isReplyFocused: FocusState<Bool>.Binding
    var isEditing: Bool = false
    let onSend: () -> Void
    let onCancel: () -> Void

    @State private var showCancelAlert: Bool = false

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
                    Text("답글을 입력하세요")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                        .allowsHitTesting(false)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 4, trailing: 10))

            HStack(spacing: 10) {
                Button {
                    if isSendActive {
                        showCancelAlert = true
                    } else {
                        onCancel()
                    }
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
        .alert(isEditing ? "수정 취소" : "작성 취소",
               isPresented: $showCancelAlert) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                onCancel()
            }
        } message: {
            Text(isEditing ? "수정 중인 답글 내용이 있습니다.\n정말 취소하시겠습니까?" : "작성 중인 답글 내용이 있습니다.\n정말 취소하시겠습니까?")
        }
    }
}

#Preview {
    @FocusState var focused: Bool
    ReplyInputBar(replyText: .constant("테스트 답글 내용"),
                  isReplyFocused: $focused,
                  onSend: {},
                  onCancel: {})
    .padding(.horizontal, 40)
    .padding(.vertical, 10)
}
