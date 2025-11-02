//
//  LoginView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel = LoginViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 10)
                    
                    Image(systemName: "figure.and.child.holdinghands")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80, alignment: .trailing)
                        .foregroundColor(Color.white)
                        .background(Color.customBlue1)
                        .cornerRadius(10)
                    
                    Text("Faith Connect")
                        .font(.title)
                        .bold()
                    
                    Text("함께 기도하는 우리 교회")
                        .font(.headline)
                        .foregroundColor(Color(.darkGray))
                        .bold()
                        .padding(.bottom, 20)
                    
                    LabeledTextField(title: "이메일",
                                     placeholder: "이메일을 입력하세요",
                                     keyboardType: .emailAddress,
                                     text: $email)
                    
                    LabeledTextField(title: "비밀번호",
                                     placeholder: "비밀번호를 입력하세요",
                                     isSecure: true,
                                     text: $password)
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        viewModel.login(email: email, password: password)
                    }) {
                        Text("로그인")
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.customBlue1)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("계정이 없으신가요? 회원가입 >")
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity)
                    }
                    
                    HStack {
                        Button(action: {
                            // 아이디찾기
                        }) {
                            Text("아이디 찾기")
                                .font(.caption2)
                    }
                        
                        Text("|")
                            .foregroundColor(Color.accentColor)
                            .font(.caption2)
                        
                        Button(action: {
                            // 비밀번호 찾기
                        }) {
                            Text("비밀번호 찾기")
                                .font(.caption2)
                        }
                    }.frame(maxWidth: .infinity)
                    
                    
                    Spacer()
                    
                    Text("교회 성도 전용 플랫폼")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity)
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                     MainView()
                 }
                .navigationDestination(isPresented: $showSignUp) {
                    SignUpView(viewModel: viewModel)
                 }
                .alert(isPresented: $viewModel.showAlert) {
                    // enum 타입 확인 후 얼랏 띄우기
                    Alert(title: Text("로그인 실패"),
                          message: Text("아이디 또는 비밀번호를 확인하세요."),
                          dismissButton: .default(Text("확인")))
                }
                .navigationBarHidden(true)
            }
        }
    }
}


struct MainView: View {
    var body: some View {
        Text("MainView")
    }
}

#Preview {
    LoginView()
}
