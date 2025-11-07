//
//  LoginViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    
    // 로그인
    // TODO: - 상태에 따라 enum으로 showAlert 처리
    func login(email: String, password: String) {
        print("로그인 email: \(email), password: \(password)")
        if (email != "" && password != "") {
            UserDefaults.standard.set(true, forKey: Constants.isLoggedIn)
        } else {
            showAlert = true
        }
    }
    
    // 아이디 찾기
    func findId() {
        print("아이디 찾기")
    }
    
    // 비밀번호 찾기
    func findPassword() {
        print("비밀번호 찾기")
    }
    
    // 회원가입
    func signUp() {
        print("회원가입")
    }
    
    
    
    
}
