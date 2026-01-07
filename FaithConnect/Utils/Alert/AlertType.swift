//
//  AlertType.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/26.
//

import SwiftUI

enum AlertType: Identifiable, Hashable {
    case loginFailure(message: String)
    case fieldEmpty(fieldName: String)
    case findIDFailure
    case passwordMismatch
    case successChangePassword
    case failureChangePassword(message: String)
    case invalidPassword
    case registerFailure(message: String)
    case registerSuccess
    case successLogout
    case categoryNotSelected
    case writeError(message: String)
    case deleteFailure(message: String)
    case serverError(action: String, message: String)
  
    var id: Int { hashValue }
    
    var title: String {
        switch self {
        case .loginFailure:
            return "로그인 실패"
        case .fieldEmpty:
            return "입력 오류"
        case .findIDFailure:
            return "아이디 찾기 실패"
        case .passwordMismatch:
            return "비밀번호 오류"
        case .successChangePassword:
            return "비밀번호 변경"
        case .failureChangePassword:
            return "비밀번호 변경 실패"
        case .invalidPassword:
            return "비밀번호 형식 오류"
        case .registerFailure:
            return "회원가입 실패"
        case .registerSuccess:
            return "회원가입 성공"
        case .successLogout:
            return "로그아웃"
        case .categoryNotSelected:
            return "카테고리를 선택해 주세요."
        case .writeError:
            return "기도 작성 실패"
        case .deleteFailure:
            return "삭제 실패"
        case .serverError:
            return "에러 발생"
        }
    }
    
    var message: String {
        switch self {
        case .loginFailure(let message):
            return message
        case .fieldEmpty(let fieldName):
            return "\(fieldName)을(를) 입력해주세요."
        case .findIDFailure:
            return "해당 정보로 가입된 아이디가 없습니다. 다시 시도해주세요."
        case .passwordMismatch:
            return "입력하신 비밀번호와 비밀번호 확인이 일치하지 않습니다. 다시 입력해주세요."
        case .successChangePassword:
            return "비밀번호가 변경되었습니다. \n 다시 로그인해주세요."
        case .failureChangePassword(let message):
            return "비밀번호 변경에 실패했습니다. 다시 시도해주세요. \n \(message)"
        case .invalidPassword:
            return "비밀번호는 영문과 숫자를 포함하여 8자 이상으로 설정해 주세요."
        case .registerFailure(let message):
            return "회원가입에 실패했습니다. 다시 시도해주세요. \n \(message)"
        case .registerSuccess:
            return "회원가입에 성공했습니다. 로그인 해주세요."
        case .successLogout:
            return "로그아웃되었습니다."
        case .categoryNotSelected:
            return "카테고리를 선택해 주세요."
        case .writeError(let message):
            return message
        case .deleteFailure(let message):
            return "삭제 실패했습니다. 다시 시도해주세요. \n \(message)"
        case .serverError(let action, let message):
            return "\(action)을(를) 실패했습니다. 다시 시도해주세요. \n \(message)"
        }
    }
}
