//
//  LoginViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

enum LoginAlert: Identifiable {
    case loginFailure(message: String)
    case fieldEmpty(fieldName: String)
    case passwordMismatch
    case successRegister
    
    var id: Int {
        switch self {
        case .loginFailure: return 0
        case .fieldEmpty: return 1
        case .passwordMismatch: return 2
        case .successRegister: return 3
        }
    }
    
    var title: String {
        switch self {
        case .loginFailure: return "로그인 실패"
        case .fieldEmpty: return "입력 오류"
        case .passwordMismatch: return "비밀번호 오류"
        case .successRegister: return "회원가입 성공"
        }
    }
    
    var message: String {
        switch self {
        case .loginFailure(let msg): return msg
        case .fieldEmpty(let fieldName): return "\(fieldName) 을(를) 입력해주세요."
        case .passwordMismatch: return "입력하신 비밀번호와 비밀번호 확인이 일치하지 않습니다. 다시 입력해주세요."
        case .successRegister: return "회원가입에 성공했습니다. 로그인 해주세요."
        }
    }
}

class LoginViewModel: ObservableObject {
    let apiService: APIServiceProtocol?
    @Published var alertType: LoginAlert? = nil
    
    init(_ apiService: APIServiceProtocol?) {
        self.apiService = apiService
    }
    
    // TODO: -
    // 1. 회원가입 v
    // 2. 로그인 v
    // 3. 아이디 찾기 v
    // 4. 비밀번호 찾기
    
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
            try await apiService?.login(email: email, password: password)
            UserDefaults.standard.set(true, forKey: Constants.isLoggedIn)
        } catch {
            let error = error.localizedDescription
            alertType = .loginFailure(message: error)
        }
    }
    
    func findID(memberID: Int, name: String) async -> String? {
        if memberID == 0 {
            alertType = .fieldEmpty(fieldName: "교번")
            return nil
        }
        
        if name.isEmpty {
            alertType = .fieldEmpty(fieldName: "이름")
            return nil
        }
        
        do {
            let foundEmail = try await apiService?.findID(memberID: memberID, name: name)
            return foundEmail
        } catch {
            let error = error.localizedDescription
            alertType = .loginFailure(message: error)
            return nil
        }
    }
    
    func findPassword() {
        print("비밀번호 찾기")
    }
    
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async {
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
            try await apiService?.signUp(memberID: memberID,
                                         name: name,
                                         email: email,
                                         password: password,
                                         confirmPassword: confirmPassword)
            alertType = .successRegister
        } catch {
            let error = error.localizedDescription
            alertType = .loginFailure(message: error)
        }
    }
    
    
}
