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
    
    init(_ apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func changePassword(id: Int, name: String, email: String, currentPassword: String, newPassword: String, confirmPassword: String) async {
        if id == 0 {
            alertType = .fieldEmpty(fieldName: "교번")
            return
        }
        
        if currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            alertType = .fieldEmpty(fieldName: "비밀번호")
            return
        }
        
        if newPassword != confirmPassword {
            alertType = .passwordMismatch
            return
        }
        
        do {
            try await apiClient.changePassword(id: id,
                                               name: name,
                                               email: email,
                                               newPassword: newPassword)
            alertType = .successChangePassword
        } catch {
            let error = error.localizedDescription
            alertType = .failureChangePassword(message: error)
        }
    }
    
    func logout() async {
        do {
            try await apiClient.logout()
            alertType = .successLogout
        } catch {
            let error = error.localizedDescription
//            alertType = .serverError(action: <#T##String#>, message: <#T##String#>)
        }
    }

}
