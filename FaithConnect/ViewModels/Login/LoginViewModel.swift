//
//  LoginViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var alertType: LoginAlert? = nil
    
    private let apiService: APIServiceProtocol
    private let session: UserSession
    
    init(_ apiService: APIServiceProtocol, _ session: UserSession) {
        self.apiService = apiService
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
            let loginResponse = try await apiService.login(email: email,
                                                           password: password)
            // TODO: - 수정 필요
            let user = User(id: 2,
                            name: "한솔",
                            email: email,
                            accessToken: loginResponse.accessToken,
                            refreshToken: loginResponse.refreshToken)
            
            let categories = try await apiService.loadCategories()
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
            let foundEmail = try await apiService.findID(memberID: memberID,
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
            try await apiService.signUp(memberID: memberID,
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
