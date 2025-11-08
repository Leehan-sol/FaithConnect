//
//  FindIDView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct FindIDView: View {
    @ObservedObject var viewModel: LoginViewModel
    //    @Environment(\.dismiss) private var dismiss
    
    @State var memberID: String = ""
    @State var name: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
                .frame(height: 10)
            
            Text("가입 시 입력한 정보로 \r이메일을 찾을 수 있습니다")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)
            
            LabeledTextField(title: "교번",
                             placeholder: "교번을 입력하세요",
                             text: $memberID)
            
            LabeledTextField(title: "이름",
                             placeholder: "이름을 입력하세요",
                             text: $name)
            .padding(.bottom, 20)
            
            ActionButton(title: "이메일 찾기",
                         backgroundColor: .customBlue1) {
                viewModel.signUp()
            }
            
            Spacer()
            
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .navigationTitle("이메일 찾기")
        .onTapGesture {
            UIApplication.shared.endEditing()
        }

    }
}

#Preview {
    FindIDView(viewModel: LoginViewModel())
}
