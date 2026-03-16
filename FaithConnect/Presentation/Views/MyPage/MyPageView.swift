//
//  MyPageView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct MyPageView: View {
    @ObservedObject var viewModel: MyPageViewModel
    @State private var showChangePassword: Bool = false
    @State private var selectedPolicy: PolicyType?
    @State var showAlert: Bool = false
    @State private var showDeleteAccount: Bool = false
    @State private var passwordResetVM: PasswordResetViewModel?
    @State private var showInquiry: Bool = false

    private let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let churchName = Bundle.main.infoDictionary?["ChurchName"] as? String
    private let apiClient: APIClientProtocol

    init(viewModel: MyPageViewModel, apiClient: APIClientProtocol) {
        self.viewModel = viewModel
        self.apiClient = apiClient
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack(spacing: 30) {
                    Image(systemName:"person.fill")
                        .resizable()
                        .foregroundColor(Color(.darkGray))
                        .frame(width: 30, height: 30)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.name)

                        Text(verbatim: viewModel.email)
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                .padding(30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                SectionHeaderView(title: "계정 설정", buttonHidden: true){}

                VStack {
                    MyPageItemField(imageName: "lock",
                                    color: .blue,
                                    titleName: "비밀번호 변경") {
                        passwordResetVM = viewModel.makePasswordResetViewModel()
                        showChangePassword = true
                    }

                    Divider()
                        .foregroundColor(Color(.systemGray6))

                    MyPageItemField(imageName: "rectangle.portrait.and.arrow.right",
                                    color: .orange,
                                    titleName: "로그아웃") {
                        showAlert = true
                    }
                }.padding(5)
                    .background()
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray6), lineWidth: 1)
                    )
                    .padding()

#if DEBUG
                SectionHeaderView(title: "개발자 도구", buttonHidden: true){}

                VStack {
                    MyPageItemField(imageName: "bell.badge",
                                    color: .green,
                                    titleName: "푸시 알림 테스트") {
                        Task {
                            await viewModel.testPush()
                        }
                    }
                }.padding(5)
                    .background()
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray6), lineWidth: 1)
                    )
                    .padding()
#endif

                SectionHeaderView(title: "정보", buttonHidden: true){}

                VStack {
                    MyPageItemField(imageName: "book.pages",
                                    color: .black,
                                    titleName: "이용약관") {
                        selectedPolicy = .terms
                    }

                    Divider()
                        .foregroundColor(Color(.systemGray6))

                    MyPageItemField(imageName: "shield",
                                    color: .black,
                                    titleName: "개인정보 처리방침") {
                        selectedPolicy = .privacy
                    }

                    Divider()
                        .foregroundColor(Color(.systemGray6))

                    MyPageItemField(imageName: "envelope",
                                    color: .black,
                                    titleName: "문의하기") {
                        showInquiry = true
                    }
                }.padding(5)
                    .background()
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray6), lineWidth: 1)
                    )
                    .padding()

                VStack(spacing: 10) {
                    Text("FaithConnect v\(versionNumber ?? "1.0.0") © \(churchName ?? "우리교회")")

                    Button {
                        showDeleteAccount = true
                    } label: {
                        Text("회원탈퇴")
                            .underline()
                    }
                }
                .padding(.top, 50)
                .font(.footnote)
                .foregroundColor(.gray)

            }
            .navigationTitle("마이페이지")
            .navigationDestination(isPresented: $showChangePassword) {
                if let vm = passwordResetVM {
                    FindPasswordView(viewModel: vm,
                                     isPresented: $showChangePassword,
                                     onResetSuccess: { viewModel.sessionLogout() },
                                     initialEmail: viewModel.email)
                }
            }
            .navigationDestination(item: $selectedPolicy) { policy in
                PolicyWebView(viewType: selectedPolicy ?? .privacy)
            }
            .sheet(isPresented: $showInquiry) {
                InquiryBottomSheetView(apiClient: apiClient,
                                       userEmail: viewModel.email,
                                       onDismissSheet: { showInquiry = false })
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
            }
            .navigationDestination(isPresented: $showDeleteAccount) {
                DeleteAccountView(viewModel: viewModel)
            }
            .alert("로그아웃", isPresented: $showAlert) {
                Button("취소", role: .cancel) { }
                Button("확인", role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                }
            } message: {
                Text("로그아웃 하시겠습니까?")
            }
            .alert(item: $viewModel.alertType) { alert in
                let dismissAction = {
                    if alert == .successLogout {
                        viewModel.sessionLogout()
                    }

                    if alert == .successChangePassword {
                        Task {
                            await viewModel.logout()
                        }
                    }
                }
                return Alert(title: Text(alert.title),
                             message: Text(alert.message),
                             dismissButton: .default(Text("확인"),
                                                     action: dismissAction))
            }
        }
    }
}

#Preview {
    let mockAPIClient = APIClient(tokenStorage: TokenStorage())
    let mockRepository = AuthRepository(apiClient: mockAPIClient)
    let mockUseCase = AuthUseCase(repository: mockRepository)
    
    MyPageView(viewModel: MyPageViewModel(authUseCase: mockUseCase,
                                          userSession: UserSession()),
              apiClient: mockAPIClient)
}


