//
//  LoginViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var showAlert: Bool = false
    
    // 로그인
    func login(email: String, password: String) {
        print("로그인 email: \(email), password: \(password)")
        if (email != "" && password != "") {
            isLoggedIn = true
        } else {
            showAlert = true
        }
    }
    
    
    // 아이디 찾기
    
    // 비밀번호 찾기
    
    
    // 회원가입
    func signUp() {
        print("회원가입")
    }
    
    
    
    
}
