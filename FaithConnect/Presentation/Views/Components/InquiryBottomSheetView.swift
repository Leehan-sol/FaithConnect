//
//  InquiryBottomSheetView.swift
//  FaithConnect
//
//  Created by hansol on 2026/03/15.
//

import SwiftUI

struct InquiryBottomSheetView: View {
    let apiClient: APIClientProtocol
    let userEmail: String
    var onDismissSheet: () -> Void

    @State var title: String = ""
    @State var content: String = ""
    @State var email: String = ""
    @State var wordCount: Int = 0
    @State var showAlert: Bool = false
    @State private var localAlert: AlertType?
    @State private var isLoading: Bool = false

    private var isSendButtonActive: Bool {
        !title.isEmpty && !content.isEmpty && !email.isEmpty
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                        .frame(height: 5)

                    Text("문의하기")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LabeledTextField(title: "답장 받을 이메일",
                                     placeholder: "example@email.com",
                                     keyboardType: .emailAddress,
                                     text: $email)

                    LabeledTextField(title: "제목",
                                     placeholder: "문의 제목을 입력하세요",
                                     text: $title)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("문의 내용")
                            .font(.subheadline)
                            .bold()

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $content)
                                .frame(height: 200)
                                .padding(EdgeInsets(top: 8,
                                                    leading: 8,
                                                    bottom: 8,
                                                    trailing: 8))
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .scrollContentBackground(.hidden)
                                .onChange(of: content) { oldValue, newValue in
                                    wordCount = newValue.count

                                    if newValue.count > 500 {
                                        content = String(newValue.prefix(500))
                                    }
                                }

                            if content.isEmpty {
                                Text("문의하실 내용을 자세히 입력해주세요")
                                    .foregroundColor(Color(uiColor: .placeholderText))
                                    .font(.body)
                                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                                    .allowsHitTesting(false)
                            }
                        }

                        Text("\(wordCount) / 500")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.caption)
                            .foregroundColor(wordCount == 500 ? .red : .gray)
                            .padding(.trailing, 8)
                    }

                    InfoBoxView(messages: [
                        "• 평일 9:00-18:00 내에 순차적으로 답변드립니다."
                    ])
                }
                .padding()

            }

            HStack {
                ActionButton(title: "취소",
                             foregroundColor: .gray,
                             backgroundColor: Color(.systemGray6)) {
                    if isSendButtonActive {
                        showAlert = true
                    } else {
                        onDismissSheet()
                    }
                }

                ActionButton(title: "전송",
                             foregroundColor: isSendButtonActive ? .white : .gray,
                             backgroundColor: isSendButtonActive ? .customBlue1 : Color(.systemGray6)) {
                    if isSendButtonActive {
                        Task {
                            await sendInquiry()
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        }
        .disabled(isLoading)
        .overlay {
            if isLoading {
                LoadingDialogView()
            }
        }
        .alert("작성 취소", isPresented: $showAlert) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                onDismissSheet()
            }
        } message: {
            Text("작성 중인 내용이 있습니다. \r 정말 취소하시겠습니까?")
        }
        .alert(item: $localAlert) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")) {
                      if case .success = alert {
                          onDismissSheet()
                      }
                  })
        }
        .onAppear {
            email = userEmail
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }

    private func sendInquiry() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await apiClient.sendInquiry(title: title,
                                             content: content,
                                             userEmail: email)
            localAlert = .success(title: "문의 완료", message: "문의가 성공적으로 전송되었습니다.")
        } catch {
            localAlert = .error(title: "문의 실패", message: error.localizedDescription)
        }
    }
}
