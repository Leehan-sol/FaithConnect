//
//  LoginViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var alertType: AlertType? = nil
    @Published var signUpAlertType: AlertType? = nil
    @Published var findIDAlertType: AlertType? = nil
    @Published var isLoading: Bool = false
    
    private let authUseCase: AuthUseCaseProtocol
    private let session: UserSession
    
    init(authUseCase: AuthUseCaseProtocol,
         session: UserSession) {
        self.authUseCase = authUseCase
        self.session = session
    }
    
    func login(email: String, password: String) async {
        print("로그인 email: \(email)")
        
        isLoading = true
        defer { isLoading = false }
        
        if email.isEmpty {
            alertType = .fieldEmpty(fieldName: "이메일")
            return
        }
        
        if password.isEmpty {
            alertType = .fieldEmpty(fieldName: "비밀번호")
            return
        }
        
        do {
            try await authUseCase.login(email: email,
                                      password: password)
            let user = try await authUseCase.fetchMyInfo()
            session.login(user: user)

            // 로그인 성공 시 푸시 토큰 등록
            if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                do {
                    try await authUseCase.registerPushToken(deviceToken: fcmToken)
                    print("푸시 토큰 등록 완료")
                } catch {
                    print("푸시 토큰 등록 실패: \(error)")
                }
            }
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "로그인 실패",
                               message: error)
        }
    }
    
    func findID(name: String) async -> String? {
        print("아이디 찾기 name: \(name)")

        if name.isEmpty {
            findIDAlertType = .fieldEmpty(fieldName: "닉네임")
            return nil
        }

        do {
            let foundEmail = try await authUseCase.findID(name: name)
            return foundEmail
        } catch {
            findIDAlertType = .error(title: "아이디 찾기 실패",
                                     message: "해당 정보로 가입된 아이디가 없습니다. 다시 시도해주세요.")
            return nil
        }
    }
    
    func makePasswordResetViewModel() -> PasswordResetViewModel {
        PasswordResetViewModel(authUseCase: authUseCase)
    }

    func makeInquiryViewModel() -> InquiryViewModel {
        InquiryViewModel(authUseCase: authUseCase)
    }

    func requestEmailVerification(email: String) async {
        if email.isEmpty {
            signUpAlertType = .fieldEmpty(fieldName: "이메일")
            return
        }

        if !isValidEmail(email: email) {
            signUpAlertType = .error(title: "이메일 형식 오류",
                                     message: "올바른 이메일 형식이 아닙니다.")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authUseCase.requestEmailVerification(email: email)
            signUpAlertType = .successEmailVerificationSent
        } catch {
            let error = error.localizedDescription
            signUpAlertType = .error(title: "인증 코드 전송 실패",
                                     message: error)
        }
    }

    func confirmEmailVerification(email: String, verificationCode: String) async -> Bool {
        if verificationCode.isEmpty {
            signUpAlertType = .fieldEmpty(fieldName: "인증 코드")
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authUseCase.confirmEmailVerification(email: email, verificationCode: verificationCode)
            return true
        } catch {
            let error = error.localizedDescription
            signUpAlertType = .error(title: "인증 실패",
                                     message: error)
            return false
        }
    }

    func signUp(name: String, email: String, password: String, confirmPassword: String) async {
        print("회원가입 name: \(name), email: \(email)")

        if name.isEmpty {
            signUpAlertType = .fieldEmpty(fieldName: "닉네임")
            return
        }

        if email.isEmpty {
            signUpAlertType = .fieldEmpty(fieldName: "이메일")
            return
        }

        if password.isEmpty {
            signUpAlertType = .fieldEmpty(fieldName: "비밀번호")
            return
        }

        if confirmPassword.isEmpty {
            signUpAlertType = .fieldEmpty(fieldName: "비밀번호 확인")
            return
        }

        if password != confirmPassword {
            signUpAlertType = .error(title: "비밀번호 오류",
                                     message: "입력하신 비밀번호와 비밀번호 확인이 일치하지 않습니다. 다시 입력해주세요.")
            return
        }

        if !isValidEmail(email: email) {
            signUpAlertType = .error(title: "이메일 형식 오류",
                                     message: "올바른 이메일 형식이 아닙니다.")
            return
        }

        if !isValidPassword(password: password) {
            signUpAlertType = .error(title: "비밀번호 형식 오류",
                                     message: "비밀번호는 영문과 숫자를 포함하여 8자 이상으로 설정해 주세요.")
            return
        }

        do {
            try await authUseCase.signUp(name: name,
                                         email: email,
                                         password: password,
                                         confirmPassword: confirmPassword)
            signUpAlertType = .registerSuccess
        } catch {
            let error = error.localizedDescription
            signUpAlertType = .error(title: "회원가입 실패",
                                     message: error)
        }
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isValidPassword(password: String) -> Bool {
        // 영문 + 숫자 포함, 8자 이상
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
}
