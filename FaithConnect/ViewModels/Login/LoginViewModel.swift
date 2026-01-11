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
    
    init(_ apiClient: APIClientProtocol, _ session: UserSession) {
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
            async let userFetch = apiClient.fetchMyInfo()
            async let categoriesFetch = try? await apiClient.loadCategories()
            
            let user = try await userFetch
            let categories = await categoriesFetch
            
            session.login(user: user, categories: categories ?? [])
        } catch {
            let error = error.localizedDescription
            alertType = .loginFailure(message: error)
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
            findIDAlertType = .findIDFailure
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
            signUpAlertType = .passwordMismatch
            return
        }
        
//        if !isValidPassword(password: password) {
//            signUpAlertType = .invalidPassword
//            return
//        }
        
        do {
            try await apiClient.signUp(memberID: memberID,
                                         name: name,
                                         email: email,
                                         password: password,
                                         confirmPassword: confirmPassword)
            signUpAlertType = .registerSuccess
        } catch {
            let error = error.localizedDescription
            signUpAlertType = .registerFailure(message: error)
        }
    }
    
    func isValidPassword(password: String) -> Bool {
        // 영문 + 숫자 포함, 8자 이상
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
}
