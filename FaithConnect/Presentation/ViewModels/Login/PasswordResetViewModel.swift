//
//  PasswordResetViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2026/03/07.
//

import Foundation

@MainActor
class PasswordResetViewModel: ObservableObject {
    @Published var findPasswordAlertType: AlertType? = nil
    @Published var resetPasswordAlertType: AlertType? = nil

    private let authUseCase: AuthUseCaseProtocol

    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }

    func requestPasswordReset(email: String) async {
        if email.isEmpty {
            findPasswordAlertType = .fieldEmpty(fieldName: "이메일")
            return
        }

        do {
            try await authUseCase.requestPasswordReset(email: email)
            findPasswordAlertType = .successPasswordResetEmail
        } catch {
            findPasswordAlertType = .error(title: "비밀번호 재설정 실패",
                                           message: error.localizedDescription)
        }
    }

    func resetPassword(email: String, code: String, newPassword: String, confirmPassword: String) async {
        if code.isEmpty {
            resetPasswordAlertType = .fieldEmpty(fieldName: "인증코드")
            return
        }

        if newPassword.isEmpty {
            resetPasswordAlertType = .fieldEmpty(fieldName: "새 비밀번호")
            return
        }

        if confirmPassword.isEmpty {
            resetPasswordAlertType = .fieldEmpty(fieldName: "비밀번호 확인")
            return
        }

        if newPassword != confirmPassword {
            resetPasswordAlertType = .error(title: "비밀번호 오류",
                                            message: "입력하신 비밀번호와 비밀번호 확인이 일치하지 않습니다.")
            return
        }

        do {
            try await authUseCase.confirmPasswordReset(email: email,
                                                              code: code,
                                                              newPassword: newPassword)
            resetPasswordAlertType = .successPasswordReset
        } catch {
            resetPasswordAlertType = .error(title: "비밀번호 재설정 실패",
                                            message: error.localizedDescription)
        }
    }
}
