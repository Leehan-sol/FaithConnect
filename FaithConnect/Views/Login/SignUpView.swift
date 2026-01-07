//
//  SignUpView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var memberID: Int? = nil
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var shouldDismiss: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                    .frame(height: 10)
                
                Text("교회 성도 인증을 위해\n정보를 입력해 주세요")
                    .font(.headline)
                    .foregroundColor(Color(.darkGray))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
                
                IntLabeledTextField(title: "교번",
                                    placeholder: "교번을 입력하세요",
                                    value: $memberID)
                
                LabeledTextField(title: "이름",
                                 placeholder: "이름을 입력하세요",
                                 text: $name)
                
                LabeledTextField(title: "이메일",
                                 placeholder: "이메일을 입력하세요",
                                 text: $email)
                
                LabeledTextField(title: "비밀번호",
                                 placeholder: "영문, 숫자 포함 8자 이상",
                                 isSecure: true,
                                 text: $password)
                
                LabeledTextField(title: "비밀번호 확인",
                                 placeholder: "비밀번호를 다시 입력하세요",
                                 isSecure: true,
                                 text: $confirmPassword)
                .padding(.bottom, 20)
                
                ActionButton(title: "회원가입",
                             foregroundColor: .white,
                             backgroundColor: .customBlue1) {
                    Task {
                        await viewModel.signUp(memberID: memberID ?? 0,
                                               name: name,
                                               email: email,
                                               password: password,
                                               confirmPassword: confirmPassword)
                    }
                }.padding(.bottom, 20)
                
                InfoBoxView(messages: [
                    "• 교번과 이름은 인증 목적으로만 사용되며 익명성이 보장됩니다.",
                    "• 모든 기도제목과 응답은 익명으로 처리됩니다.",
                    "• 개인정보는 안전하게 보호됩니다."])
                
                Spacer()
                
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .navigationTitle("회원가입")
            .customBackButtonStyle()
            .alert(item: $viewModel.alertType) { alert in
                let dismissAction = {
                    if case .registerSuccess = alert {
                        shouldDismiss = true
                    }
                }
                return Alert(title: Text(alert.title),
                             message: Text(alert.message),
                             dismissButton: .default(Text("확인"),
                                                     action: dismissAction))
            }
        }
        .onChange(of: shouldDismiss) {
            if shouldDismiss { dismiss() }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
}

#Preview {
    SignUpView(viewModel: LoginViewModel(APIClient(tokenStorage: TokenStorage()),
                                         UserSession()))
}
