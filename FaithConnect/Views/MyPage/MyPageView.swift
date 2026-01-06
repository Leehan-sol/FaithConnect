//
//  MyPageView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var session: UserSession
    @ObservedObject var viewModel: MyPageViewModel
    @State private var showChangePassword: Bool = false
    @State private var selectedPolicy: PolicyType?
    @State var showAlert: Bool = false
    
    private let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let churchName = Bundle.main.infoDictionary?["ChurchName"] as? String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack(spacing: 30) {
                    Image(systemName:"person.fill")
                        .resizable()
                        .foregroundColor(Color(.darkGray))
                        .frame(width: 30, height: 30)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(session.name)
                        
                        Text(verbatim: session.email)
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
                        // 회원탈퇴
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
                ChangePasswordView(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedPolicy) { policy in
                PolicyWebView(viewType: selectedPolicy ?? .privacy)
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
                        session.logout()
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
    MyPageView(viewModel: MyPageViewModel(APIClient(tokenStorage: TokenStorage())))
        .environmentObject(UserSession())
}

