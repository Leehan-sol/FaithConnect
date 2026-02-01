//
//  MyPageViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

@MainActor
class MyPageViewModel: ObservableObject {
    @Published var alertType: AlertType? = nil
    
    private let apiClient: APIClientProtocol
    private let userSession: UserSession
    
    // TODO: - userSession의 name, email쓰는거로 수정 필요
    let name = ""
    let email = ""
    
    init(apiClient: APIClientProtocol, userSession: UserSession) {
        self.apiClient = apiClient
        self.userSession = userSession
    }
    

    
    func changePassword(id: Int, currentPassword: String, newPassword: String, confirmPassword: String) async {
        if id == 0 {
            alertType = .fieldEmpty(fieldName: "교번")
            return
        }
        
        if currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            alertType = .fieldEmpty(fieldName: "비밀번호")
            return
        }
        
        if newPassword != confirmPassword {
            alertType = .error(title: "비밀번호 오류",
                               message: "입력하신 비밀번호와 비밀번호 확인이 일치하지 않습니다. 다시 입력해주세요.")
            return
        }
        
        do {
            try await apiClient.changePassword(id: id,
                                               name: userSession.name,
                                               email: userSession.email,
                                               newPassword: newPassword)
            alertType = .successChangePassword
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "비밀번호 변경 실패",
                               message: error)
        }
    }
    
    func logout() async {
        do {
            try await apiClient.logout()
            alertType = .successLogout
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "로그아웃",
                               message: error)
        }
    }

    
    func sessionLogout() {
        userSession.logout()
    }
    
}
