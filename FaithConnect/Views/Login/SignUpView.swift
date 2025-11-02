//
//  SignUpView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: LoginViewModel
//    @Environment(\.dismiss) private var dismiss
    
    @State var memberID: String = ""
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
                .frame(height: 10)
        
            Text("교회 성도 인증을 위해\n정보를 입력해 주세요")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 10)
            
            LabeledTextField(title: "교번",
                             placeholder: "교번을 입력하세요",
                             text: $memberID)
            
            LabeledTextField(title: "이름",
                             placeholder: "이름을 입력하세요",
                             text: $name)
            
            LabeledTextField(title: "이메일",
                             placeholder: "이메일을 입력하세요",
                             text: $email)
            
            LabeledTextField(title: "비밀번호",
                             placeholder: "비밀번호를 입력하세요",
                             text: $password)
            
            LabeledTextField(title: "비밀번호 확인",
                             placeholder: "비밀번호를 다시 입력하세요",
                             text: $confirmPassword)
            .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing:5) {
                Text("• 교번과 이름은 인증 목적으로만 사용되며 익명성이 보장됩니다.")
                Text("• 모든 기도제목과 응답은 익명으로 처리됩니다.")
                Text("• 개인정보는 안전하게 보호됩니다.")
            }
            .font(.caption)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.bottom, 20)
          
            Button(action: {
                viewModel.signUp()
            }) {
                Text("회원가입")
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customBlue1)
                    .cornerRadius(10)
            }
            
            Spacer()
            
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .navigationTitle("회원가입")
    }
        
}

#Preview {
    SignUpView(viewModel: LoginViewModel())
}
