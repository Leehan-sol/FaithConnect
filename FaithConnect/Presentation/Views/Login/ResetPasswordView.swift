//
//  ResetPasswordView.swift
//  FaithConnect
//
//  Created by Claude on 2026/03/05.
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Binding var isPresented: Bool

    @State private var verificationCode: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    let email: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
                .frame(height: 10)

            Text("이메일로 전송된 인증코드를 입력하고\n새 비밀번호를 설정해주세요")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)

            LabeledTextField(title: "인증코드",
                             placeholder: "인증코드를 입력하세요",
                             text: $verificationCode)

            LabeledTextField(title: "새 비밀번호",
                             placeholder: "새 비밀번호를 입력하세요",
                             isSecure: true,
                             text: $newPassword)

            LabeledTextField(title: "새 비밀번호 확인",
                             placeholder: "새 비밀번호를 다시 입력하세요",
                             isSecure: true,
                             text: $confirmPassword)
            .padding(.bottom, 20)

            ActionButton(title: "완료",
                         foregroundColor: .white,
                         backgroundColor: .customBlue1) {
                Task {
                    await viewModel.resetPassword(email: email,
                                                  code: verificationCode,
                                                  newPassword: newPassword,
                                                  confirmPassword: confirmPassword)
                }
            }

            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .navigationTitle("비밀번호 재설정")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
        .alert(item: $viewModel.resetPasswordAlertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")) {
                      if alert == .successPasswordReset {
                          isPresented = false
                      }
                  })
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

#Preview {
    let mockAuthUseCase = AuthUseCase(repository: AuthRepository(apiClient: APIClient(tokenStorage: TokenStorage())))
    let mockSession = UserSession()

    ResetPasswordView(viewModel: LoginViewModel(authUseCase: mockAuthUseCase,
                                                session: mockSession),
                      isPresented: .constant(true),
                      email: "test@test.com")
}
