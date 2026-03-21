//
//  AlertType.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/26.
//

import SwiftUI

enum AlertType: Identifiable, Hashable {
    case error(title: String = "에러", message: String)
    case success(title: String = "성공", message: String)
    case fieldEmpty(fieldName: String)
    case successChangePassword
    case registerSuccess
    case successLogout
    case successDeleteAccount
    case successPasswordResetEmail
    case successPasswordReset

    var id: Int { hashValue }

    var title: String {
        switch self {
        case .error(let title, _):
            return title
        case .success(let title, _):
            return title
        case .fieldEmpty:
            return "입력 오류"
        case .successChangePassword:
            return "비밀번호 변경"
        case .registerSuccess:
            return "회원가입 성공"
        case .successLogout:
            return "로그아웃"
        case .successDeleteAccount:
            return "회원탈퇴"
        case .successPasswordResetEmail:
            return "이메일 전송 완료"
        case .successPasswordReset:
            return "비밀번호 재설정"
        }
    }

    var message: String {
        switch self {
        case .error(_, let message):
            return message
        case .success(_, let message):
            return message
        case .fieldEmpty(let fieldName):
            return "\(fieldName)을(를) 입력해주세요."
        case .successChangePassword:
            return "비밀번호가 변경되었습니다. \n다시 로그인해주세요."
        case .registerSuccess:
            return "회원가입에 성공했습니다. \n로그인 해주세요."
        case .successLogout:
            return "로그아웃되었습니다."
        case .successDeleteAccount:
            return "회원탈퇴가 완료되었습니다."
        case .successPasswordResetEmail:
            return "입력하신 이메일로 인증코드를 전송했습니다."
        case .successPasswordReset:
            return "비밀번호가 재설정되었습니다. \n새 비밀번호로 로그인해주세요."
        }
    }
}
