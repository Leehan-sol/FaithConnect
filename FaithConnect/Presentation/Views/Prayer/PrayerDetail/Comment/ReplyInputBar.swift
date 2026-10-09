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
    var isManna: Bool = false
    var parentVisibility: Visibility? = nil
    let onSend: (_ visibility: Visibility?, _ displayNameType: DisplayNameType?) -> Void
    let onCancel: () -> Void

    @State private var showCancelAlert: Bool = false
    @State private var selectedVisibility: Visibility = .publicAll
    @State private var selectedDisplayNameType: DisplayNameType = .nickname

    private var isVisibilityLocked: Bool {
        parentVisibility == .pastorOnly
    }

    private var wordCount: Int {
        replyText.count
    }

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
                    .onChange(of: replyText) { oldValue, newValue in
                        if newValue.count > 500 {
                            replyText = String(newValue.prefix(500))
                        }
                    }

                if replyText.isEmpty {
                    Text("답글을 입력하세요")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                        .allowsHitTesting(false)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 4, trailing: 10))

            HStack {
                Spacer()
                Text("\(wordCount) / 500")
                    .font(.caption)
                    .foregroundColor(wordCount >= 500 ? .red : .gray)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10))

            if isManna {
                VStack(spacing: 0) {
                    if !isVisibilityLocked {
                        HStack {
                            Text("공개범위")
                                .font(.caption)
                            Spacer()
                            Picker("", selection: $selectedVisibility) {
                                Text("전체").tag(Visibility.publicAll)
                                Text("비공개").tag(Visibility.pastorOnly)
                            }
                            .tint(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                        Divider()
                            .padding(.leading, 12)
                    }

                    HStack {
                        Text("표시이름")
                            .font(.caption)
                        Spacer()
                        Picker("", selection: $selectedDisplayNameType) {
                            ForEach(DisplayNameType.allCases, id: \.self) { t in
                                Text(t.displayName).tag(t)
                            }
                        }
                        .tint(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
            }

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
                    let vis = isManna ? (isVisibilityLocked ? .pastorOnly : selectedVisibility) : nil
                    let dnt = isManna ? selectedDisplayNameType : nil
                    onSend(vis, dnt)
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
        .onAppear {
            if isVisibilityLocked {
                selectedVisibility = .pastorOnly
            }
        }
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
                  onSend: { _, _ in },
                  onCancel: {})
    .padding(.horizontal, 40)
    .padding(.vertical, 10)
}
