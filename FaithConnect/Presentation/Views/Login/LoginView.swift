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
    @State private var showInquiry: Bool = false
    @State private var passwordResetVM: PasswordResetViewModel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            Spacer()
                                .frame(height: 10)

                            Image("heartIcon")
                                .resizable()
                                .frame(width: 120, height: 120)

                            Text("Faith Connect")
                                .font(.title)
                                .bold()

                            Text("함께 기도하는 우리 교회")
                                .font(.headline)
                                .foregroundColor(Color(.darkGray))
                                .bold()
                                .padding(.bottom, 0)

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
                                    passwordResetVM = viewModel.makePasswordResetViewModel()
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
                                    await viewModel.login(email: email,
                                                          password: password)
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
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }

                    Spacer()

                    Button {
                        showInquiry = true
                    } label: {
                        Text("문의하기")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 16)
                }.disabled(viewModel.isLoading)
 
                if viewModel.isLoading {
                    LoadingDialogView()
                }
                
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(viewModel: viewModel,
                           isPresented: $showSignUp)
            }
            .navigationDestination(isPresented: $showFindID) {
                FindIDView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showFindPW) {
                if let vm = passwordResetVM {
                    FindPasswordView(viewModel: vm, isPresented: $showFindPW)
                }
            }
            .sheet(isPresented: $showInquiry) {
                InquiryBottomSheetView(viewModel: viewModel.makeInquiryViewModel(),
                                       userEmail: "",
                                       onDismissSheet: { showInquiry = false })
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
            }
            .alert(item: $viewModel.alertType) { alert in
                Alert(title: Text(alert.title),
                      message: Text(alert.message),
                      dismissButton: .default(Text("확인")))
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
}

#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockAuthUseCase = AuthUseCase(repository: AuthRepository(apiClient: mockAPIClient))
    let mockSession = UserSession()

    return LoginView(viewModel: LoginViewModel(authUseCase: mockAuthUseCase,
                                               session: mockSession))
}
