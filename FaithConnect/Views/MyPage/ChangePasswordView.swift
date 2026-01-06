//
//  ChangePasswordView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/30.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject private var session: UserSession
    @ObservedObject var viewModel: MyPageViewModel

    @State var churchId: Int?
    @State var password: String = ""
    @State var newPassword: String = ""
    @State var confirmNewPassword: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
                .frame(height: 10)
            
            Text("보안을 위해 현재 비밀번호를 먼저 확인합니다")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)
            
            IntLabeledTextField(title: "교번",
                                placeholder: "교번을 입력하세요",
                                value: $churchId)
            
            LabeledTextField(title: "현재 비밀번호",
                             placeholder: "현재 비밀번호를 입력하세요",
                             isSecure: true,
                             text: $password)
            
            LabeledTextField(title: "새 비밀번호",
                             placeholder: "새 비밀번호를 입력하세요",
                             isSecure: true,
                             text: $newPassword)
            
            LabeledTextField(title: "새 비밀번호 확인",
                             placeholder: "새 비밀번호를 다시 입력하세요",
                             isSecure: true,
                             text: $confirmNewPassword)
            .padding(.bottom, 20)
            
            ActionButton(title: "비밀번호 변경",
                         foregroundColor: .white,
                         backgroundColor: .customBlue1) {
                Task {
                    await viewModel.changePassword(id: churchId ?? 0,
                                                   name: session.name,
                                                   email: session.email,
                                                   currentPassword: password,
                                                   newPassword: newPassword,
                                                   confirmPassword: confirmNewPassword)
                }
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .navigationTitle("비밀번호 변경")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
    }
    
}


#Preview {
    ChangePasswordView(viewModel: MyPageViewModel(APIClient(tokenStorage: TokenStorage())))
        .environmentObject(UserSession())
}
