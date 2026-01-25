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
    
    private let apiClient: APIClientProtocol
    private let session: UserSession
    
    init(apiClient: APIClientProtocol,
         session: UserSession) {
        self.apiClient = apiClient
        self.session = session
    }
    
    func login(email: String, password: String) async {
        print("로그인 email: \(email), password: \(password)")
        
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
            try await apiClient.login(email: email,
                                      password: password)
            // 테스트용 코드
//            TokenStorage().saveToken(accessToken: "wrong_token", refreshToken: TokenStorage().refreshToken ?? "")
            let user = try await apiClient.fetchMyInfo()
            session.login(user: user)
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "로그인 실패",
                               message: error)
        }
    }
    
    func findID(memberID: Int, name: String) async -> String? {
        print("아이디 찾기 memberID: \(memberID), name: \(name)")
        if memberID == 0 {
            findIDAlertType = .fieldEmpty(fieldName: "교번")
            return nil
        }
        
        if name.isEmpty {
            findIDAlertType = .fieldEmpty(fieldName: "이름")
            return nil
        }
        
        do {
            let foundEmail = try await apiClient.findID(memberID: memberID,
                                                         name: name)
            return foundEmail
        } catch {
            findIDAlertType = .error(title: "아이디 찾기 실패",
                                     message: "해당 정보로 가입된 아이디가 없습니다. 다시 시도해주세요.")
            return nil
        }
    }
    
    func findPassword() {
        print("비밀번호 찾기")
    }
    
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async {
        print("회원가입 memberID: \(memberID), name: \(name), email: \(email), password: \(password), confirmPassword: \(confirmPassword)")
        if memberID == 0 {
            signUpAlertType = .fieldEmpty(fieldName: "교번")
            return
        }
        
        if name.isEmpty {
            signUpAlertType = .fieldEmpty(fieldName: "이름")
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
            try await apiClient.signUp(memberID: memberID,
                                         name: name,
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
