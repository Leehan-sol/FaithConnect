//
//  SignUpFormView.swift
//  FaithConnect
//

import SwiftUI

struct SignUpFormView: View {
    let church: Church
    let community: CommunityItem?
    @ObservedObject var viewModel: LoginViewModel
    @State private var name = ""
    @State private var nickname = ""
    @State private var email = ""
    @State private var verificationCode = ""
    @State private var isEmailVerified = false
    @State private var isVerificationCodeSent = false
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Spacer().frame(height: 10)

                // MARK: - 소속 정보
                VStack(alignment: .leading, spacing: 10) {
                    Text("소속")
                        .font(.subheadline)
                        .bold()

                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.customBlue1)
                            .frame(width: 40, height: 40)
                            .background(Color.customBlue1.opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(church.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                if let community = community {
                                    Text(community.displayName)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.customBlue1.opacity(0.15))
                                        .foregroundColor(.customBlue1)
                                        .clipShape(Capsule())
                                }
                            }

                            if !church.roadAddress.isEmpty {
                                Text(church.roadAddress)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Spacer(minLength: 0)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.bottom, 10)

                // MARK: - 기본 정보
                LabeledTextField(title: "이름",
                                 placeholder: "이름을 입력하세요",
                                 text: $name)

                LabeledTextField(title: "닉네임",
                                 placeholder: "닉네임을 입력하세요",
                                 maxLength: 50,
                                 text: $nickname)

                // MARK: - 이메일 인증
                VStack(alignment: .leading, spacing: 10) {
                    Text("이메일")
                        .font(.subheadline)
                        .bold()

                    HStack(spacing: 8) {
                        TextField("이메일을 입력하세요", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disabled(isEmailVerified)

                        Button {
                            Task {
                                await viewModel.requestEmailVerification(email: email)
                            }
                        } label: {
                            Text(isVerificationCodeSent ? "재전송" : "인증요청")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 80)
                                .padding(.vertical, 16)
                                .background(isEmailVerified ? Color.gray : Color.customBlue1)
                                .cornerRadius(10)
                        }
                        .disabled(isEmailVerified)
                    }

                    if isVerificationCodeSent && !isEmailVerified {
                        HStack(spacing: 8) {
                            TextField("인증 코드를 입력하세요", text: $verificationCode)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            Button {
                                Task {
                                    let success = await viewModel.confirmEmailVerification(
                                        email: email,
                                        verificationCode: verificationCode
                                    )
                                    if success { isEmailVerified = true }
                                }
                            } label: {
                                Text("확인")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 80)
                                    .padding(.vertical, 16)
                                    .background(Color.customBlue1)
                                    .cornerRadius(10)
                            }
                        }
                    }

                    if isEmailVerified {
                        Text("이메일 인증이 완료되었습니다.")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                // MARK: - 비밀번호
                LabeledTextField(title: "비밀번호",
                                 placeholder: "영문, 숫자 포함 8자 이상",
                                 isSecure: true,
                                 text: $password)

                LabeledTextField(title: "비밀번호 확인",
                                 placeholder: "비밀번호를 다시 입력하세요",
                                 isSecure: true,
                                 text: $confirmPassword)
                .padding(.bottom, 20)

                // MARK: - 가입 버튼
                ActionButton(title: "회원가입",
                             foregroundColor: .white,
                             backgroundColor: isEmailVerified ? .customBlue1 : .gray) {
                    Task {
                        await viewModel.signUp(name: name,
                                               nickname: nickname,
                                               email: email,
                                               password: password,
                                               confirmPassword: confirmPassword,
                                               church: church,
                                               community: community)
                    }
                }
                .disabled(!isEmailVerified)
                .padding(.bottom, 20)

                InfoBoxView(messages: [
                    "• 이메일은 인증 목적으로만 사용되며 다른 사용자에게 공개되지 않습니다.",
                    "• 이름은 본인 확인 용도로만 사용됩니다.",
                    "• 닉네임은 다른 사용자에게 표시될 수 있습니다.",
                    "• 개인정보는 안전하게 보호됩니다."])

                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        }
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButtonStyle()
        .alert(item: $viewModel.signUpAlertType) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("확인")) {
                if case .registerSuccess = alert {
                    dismiss()
                }
                if case .successEmailVerificationSent = alert {
                    isVerificationCodeSent = true
                }
            })
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}
