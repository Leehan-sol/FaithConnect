//
//  FindPasswordView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct FindPasswordView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss

    @State var email: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
                .frame(height: 10)
            
            Text("등록된 이메일 주소로 \r비밀번호 재설정 링크를 보내드립니다")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)
            
            LabeledTextField(title: "이메일",
                             placeholder: "이메일을 입력하세요",
                             text: $email)
            .padding(.bottom, 20)
            
            ActionButton(title: "재설정 링크 전송",
                         foregroundColor: .white,
                         backgroundColor: .customBlue1) {
                
            }.padding(.bottom, 20)
            
            InfoBoxView(messages: [
                "💡 이메일이 도착하지 않으면 스팸 메일함을 확인해주세요."])
            
            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .navigationTitle("비밀번호 변경")
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

#Preview {
    FindPasswordView(viewModel: LoginViewModel(APIService()))
}
