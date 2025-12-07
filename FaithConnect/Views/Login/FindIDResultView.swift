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
            
            (foundID.isEmpty
             ? Image(systemName: "xmark")
             : Image(systemName: "checkmark")
            )
            .foregroundColor(foundID.isEmpty ? .red : .green)
            .bold()
            .frame(width: 80, height: 80)
            .background(foundID.isEmpty
                        ? .red.opacity(0.2)
                        : .green.opacity(0.2))
            .cornerRadius(40)
            .padding(30)
            
            (foundID.isEmpty
             ? Text("이메일을 찾을 수 없습니다")
             : Text("이메일을 찾았습니다")
            )
            .font(.title3)
            .bold()
            
            (foundID.isEmpty
             ? Text("입력하신 정보와 일치하는 계정이 없습니다")
             : Text("입력하신 정보와 일치하는 이메일입니다")
            )
            .foregroundColor(Color(.darkGray))
            .padding(.bottom, 40)
            
            
            if foundID.isEmpty {
                InfoBoxView(messages: [
                    "• 이름과 교번을 정확히 입력했는지 확인해주세요.",
                    "• 회원가입 시 입력한 정보와 동일해야 합니다.",
                    "• 계속 문제가 발생하면 교회 관리자에게 문의해주세요."
                ])
                .padding(.bottom, 40)
            } else {
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
            }
            
            if foundID.isEmpty {
                ActionButton(title: "다시 시도하기",
                             foregroundColor: .white,
                             backgroundColor: .customBlue1) {
                    dismiss()
                }
                ActionButton(title: "로그인 화면으로",
                             foregroundColor: .black,
                             backgroundColor: Color(.systemGray6)) {
                    dismiss()
                    onComplete()
                }
            } else {
                ActionButton(title: "로그인하기",
                             foregroundColor: .white,
                             backgroundColor: .customBlue1) {
                    dismiss()
                    onComplete()
                }
            }
            
            Spacer()
            
        }.padding()
            .navigationBarHidden(true)
    }
}

#Preview {
    FindIDResultView(foundID: "") {
        //        dismiss()
    }
}
