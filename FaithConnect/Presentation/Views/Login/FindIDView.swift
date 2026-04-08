//
//  FindIDView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct FindIDView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var findID: String = ""
    @State private var findingID: Bool = false
    @State private var showFindID: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
                .frame(height: 10)
            
            Text("가입 시 입력한 닉네임으로 \r이메일을 찾을 수 있습니다")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)

            // TODO: 서버 API 변경 후 이름(name)으로 찾기로 확정 (닉네임 → 이름)
            LabeledTextField(title: "닉네임",
                             placeholder: "닉네임을 입력하세요",
                             text: $name)
            .padding(.bottom, 20)
            
            ActionButton(title: findingID ? "찾는 중..." : "이메일 찾기",
                         foregroundColor: .white,
                         backgroundColor: findingID ? .gray : .customBlue1) {
                Task {
                    findingID = true
                    defer { findingID = false }
                    
                    if let resultID = await viewModel.findID(name: name) {
                        findID = resultID
                        showFindID = true
                    }
                }
            }.disabled(findingID)
            
            Spacer()
            
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .navigationTitle("이메일 찾기")
        .navigationDestination(isPresented: $showFindID) {
            FindIDResultView(foundID: findID) {
                dismiss()
            }
        }
        .customBackButtonStyle()
        .alert(item: $viewModel.findIDAlertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")))
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}


#Preview {
    let mockAuthUseCase = AuthUseCase(repository: AuthRepository(apiClient: APIClient(tokenStorage: TokenStorage())))
    let mockSession = UserSession()

    return FindIDView(viewModel: LoginViewModel(authUseCase: mockAuthUseCase,
                                                session: mockSession))
}
