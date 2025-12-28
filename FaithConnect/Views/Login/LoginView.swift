//
//  LoginView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp: Bool = false
    @State private var showFindID: Bool = false
    @State private var showFindPW: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                        .frame(height: 10)
                    
                    Image(systemName: "figure.and.child.holdinghands")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80, alignment: .trailing)
                        .foregroundColor(.white)
                        .background(.customBlue1)
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
                    
                    HStack {
                        Button(action: {
                            showFindID = true
                        }) {
                            Text("이메일 찾기")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        Text("|")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showFindPW = true
                        }) {
                            Text("비밀번호 찾기")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    ActionButton(title: "로그인",
                                 foregroundColor: .white,
                                 backgroundColor: .customBlue1) {
                        Task {
                            await viewModel.login(email: email, password: password)
                        }
                    }
                    
                    Button(action: {
                        showSignUp = true
                    }) {
                        HStack(spacing: 5) {
                            Text("계정이 없으신가요? 회원가입")
                                .foregroundStyle(Color.accentColor)
                            
                            Image(systemName: "chevron.forward")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                    
                    Text("교회 성도 전용 플랫폼")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .navigationBarHidden(true)
                .navigationDestination(isPresented: $showSignUp) {
                    SignUpView(viewModel: viewModel)
                }
                .navigationDestination(isPresented: $showFindID) {
                    FindIDView(viewModel: viewModel)
                }
                .navigationDestination(isPresented: $showFindPW) {
                    FindPasswordView(viewModel: viewModel)
                }
                .alert(item: $viewModel.alertType) { alert in
                    Alert(title: Text(alert.title),
                          message: Text(alert.message),
                          dismissButton: .default(Text("확인")))
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(APIService(), UserSession()))
}
