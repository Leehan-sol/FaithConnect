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
    @Published var deleteAccountAlert: AlertType? = nil

    private let authUseCase: AuthUseCaseProtocol
    private let userSession: UserSession

    var name: String { userSession.name }
    var email: String { userSession.email }

    init(authUseCase: AuthUseCaseProtocol, userSession: UserSession) {
        self.authUseCase = authUseCase
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
            try await authUseCase.changePassword(id: id,
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
            if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                try? await authUseCase.deletePushToken(deviceToken: fcmToken)
                print("푸시 토큰 삭제 완료")
            }
            try await authUseCase.logout()
            alertType = .successLogout
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "로그아웃",
                               message: error)
        }
    }

    func deleteAccount() async {
        do {
            if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                try? await authUseCase.deletePushToken(deviceToken: fcmToken)
                print("푸시 토큰 삭제 완료")
            }
            try await authUseCase.deleteAccount()
            deleteAccountAlert = .successDeleteAccount
        } catch {
            let error = error.localizedDescription
            deleteAccountAlert = .error(title: "회원탈퇴 실패",
                                        message: error)
        }
    }

    func testPush() async {
        do {
            try await authUseCase.testPush(
                title: "FaithConnect 테스트",
                body: "푸시 알림 테스트입니다.",
                data: ["type": "PRAYER_RESPONSE",
                       "prayerRequestId": "123"]
            )
            alertType = .error(title: "푸시 테스트", message: "푸시 알림 전송 요청 성공")
        } catch {
            alertType = .error(title: "푸시 테스트 실패", message: error.localizedDescription)
        }
    }

    func makePasswordResetViewModel() -> PasswordResetViewModel {
        PasswordResetViewModel(authUseCase: authUseCase)
    }

    func sessionLogout() {
        userSession.logout()
    }

}
