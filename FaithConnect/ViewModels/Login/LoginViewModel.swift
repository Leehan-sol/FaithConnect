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
    
    private let apiClient: APIClientProtocol
    private let session: UserSession
    
    init(_ apiClient: APIClientProtocol, _ session: UserSession) {
        self.apiClient = apiClient
        self.session = session
    }
    
    func login(email: String, password: String) async {
        print("로그인 email: \(email), password: \(password)")
        
        if email.isEmpty {
            alertType = .fieldEmpty(fieldName: "이메일")
            return
        }
        
        if password.isEmpty {
            alertType = .fieldEmpty(fieldName: "비밀번호")
            return
        }
        
        do {
            let loginResponse = try await apiClient.login(email: email,
                                                           password: password)
            let user = User(id: 11,
                            name: loginResponse.name,
                            email: loginResponse.email,
                            accessToken: loginResponse.accessToken,
                            refreshToken: loginResponse.refreshToken)
            
            let categories = try await apiClient.loadCategories()
            session.login(user: user, categories: categories)
        } catch {
            let error = error.localizedDescription
            alertType = .loginFailure(message: error)
        }
    }
    
    func findID(memberID: Int, name: String) async -> String? {
        print("아이디 찾기 memberID: \(memberID), name: \(name)")
        if memberID == 0 {
            alertType = .fieldEmpty(fieldName: "교번")
            return nil
        }
        
        if name.isEmpty {
            alertType = .fieldEmpty(fieldName: "이름")
            return nil
        }
        
        do {
            let foundEmail = try await apiClient.findID(memberID: memberID,
                                                         name: name)
            return foundEmail
        } catch {
            alertType = .findIDFailure
            return nil
        }
    }
    
    func findPassword() {
        print("비밀번호 찾기")
    }
    
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async {
        print("회원가입 memberID: \(memberID), name: \(name), email: \(email), password: \(password), confirmPassword: \(confirmPassword)")
        if memberID == 0 {
            alertType = .fieldEmpty(fieldName: "교번")
            return
        }
        
        if name.isEmpty {
            alertType = .fieldEmpty(fieldName: "이름")
            return
        }
        
        if email.isEmpty {
            alertType = .fieldEmpty(fieldName: "이메일")
            return
        }
        
        if password.isEmpty {
            alertType = .fieldEmpty(fieldName: "비밀번호")
            return
        }
        
        if confirmPassword.isEmpty {
            alertType = .fieldEmpty(fieldName: "비밀번호 확인")
            return
        }
        
        if password != confirmPassword {
            alertType = .passwordMismatch
            return
        }
        
        do {
            try await apiClient.signUp(memberID: memberID,
                                         name: name,
                                         email: email,
                                         password: password,
                                         confirmPassword: confirmPassword)
            alertType = .registerSuccess
        } catch {
            let error = error.localizedDescription
            alertType = .registerFailure(message: error)
        }
    }
    
    
}
