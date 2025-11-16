//
//  FindIDResultView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/16.
//

import SwiftUI

struct FindIDResultView: View {
    @Environment(\.dismiss) private var dismiss
    let foundID: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
                .frame(height: 20)
            
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .bold()
                .frame(width: 80, height: 80)
                .background(.green.opacity(0.2))
                .cornerRadius(40)
                .padding(30)
            
            Text("이메일을 찾았습니다")
                .font(.title3)
                .bold()
            
            Text("입력하신 정보와 일치하는 이메일입니다")
                .foregroundColor(Color(.darkGray))
                .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("등록된 이메일")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(foundID)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.bottom, 40)
            
            ActionButton(title: "로그인하기",
                         foregroundColor: .white,
                         backgroundColor: .customBlue1) {
                dismiss()
                onComplete()
            }
            
            Spacer()
            
        }.padding()
        .navigationBarHidden(true)
    }
}

#Preview {
    FindIDResultView(foundID: "test1@naver.com") {
        //        dismiss()
    }
}
