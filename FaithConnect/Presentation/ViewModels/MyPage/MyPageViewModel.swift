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
    private let prayerUseCase: PrayerUseCaseProtocol
    private let userSession: UserSession

    var name: String { userSession.name }
    var nickname: String { userSession.nickname }
    var email: String { userSession.email }

    init(authUseCase: AuthUseCaseProtocol, prayerUseCase: PrayerUseCaseProtocol, userSession: UserSession) {
        self.authUseCase = authUseCase
        self.prayerUseCase = prayerUseCase
        self.userSession = userSession
    }
    
    func changeNickname(nickname: String) async {
        if nickname.isEmpty {
            alertType = .fieldEmpty(fieldName: "닉네임")
            return
        }

        do {
            let updatedNickname = try await authUseCase.changeNickname(nickname: nickname)
            userSession.updateNickname(updatedNickname)
            alertType = .success(title: "닉네임 변경", message: "닉네임이 변경되었습니다.")
        } catch {
            alertType = .error(title: "닉네임 변경 실패", message: error.localizedDescription)
        }
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
        /*
        1. 딴사람이 기도 올렸을때 받기
        {
          "notification": {
            "title": "새로운 기도제목이 등록되었습니다",
            "body": "홍길동님이 새로운 기도제목을 올렸습니다: 건강을 위한 기도"
          },
          "data": {
            "type": "PRAYER_REQUEST",
            "prayerRequestId": "123"
          }
        }

        2. 내가 응답 올렸을때 기도 올린 사람이 받기
        {
          "notification": {
            "title": "새로운 기도 응답이 있습니다",
            "body": "김철수님이 기도제목에 응답했습니다: 건강을 위한 기도"
          },
          "data": {
            "type": "PRAYER_RESPONSE",
            "prayerRequestId": "123"
          }
         
        }
         */
        
        alertType = .error(title: "푸시 테스트", message: "5초 후 푸시 알림이 발송됩니다.")
        try? await Task.sleep(nanoseconds: 5_000_000_000)

        do {
            try await authUseCase.testPush(
                title: "새로운 기도제목이 등록되었습니다",
                body: "홍길동님이 새로운 기도제목을 올렸습니다: 건강을 위한 기도",
                data: ["type": "PRAYER_REQUEST",
                       "prayerRequestId": "15"]
            )
        } catch {
            alertType = .error(title: "푸시 테스트 실패", message: error.localizedDescription)
        }
    }

    func makePasswordResetViewModel() -> PasswordResetViewModel {
        PasswordResetViewModel(authUseCase: authUseCase)
    }

    func makeInquiryViewModel() -> InquiryViewModel {
        InquiryViewModel(authUseCase: authUseCase)
    }

    func makeBlockListViewModel() -> BlockListViewModel {
        BlockListViewModel(prayerUseCase: prayerUseCase)
    }

    func sessionLogout() {
        userSession.logout()
    }

}
