//
//  AlertType.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/26.
//

import SwiftUI

enum LoginAlert: Identifiable {
    case loginFailure(message: String)
    case fieldEmpty(fieldName: String)
    case findIDFailure
    case passwordMismatch
    case registerFailure(message: String)
    case registerSuccess
    
    var id: Int {
        switch self {
        case .loginFailure: return 0
        case .fieldEmpty: return 1
        case .findIDFailure: return 2
        case .passwordMismatch: return 3
        case .registerFailure: return 4
        case .registerSuccess: return 5
        }
    }
    
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
        case .registerFailure:
            return "회원가입 실패"
        case .registerSuccess:
            return "회원가입 성공"
        }
    }
    
    var message: String {
        switch self {
        case .loginFailure(let message):
            return message
        case .fieldEmpty(let fieldName):
            return "\(fieldName) 을(를) 입력해주세요."
        case .findIDFailure:
            return "아이디 찾기를 실패했습니다."
        case .passwordMismatch:
            return "입력하신 비밀번호와 비밀번호 확인이 일치하지 않습니다. 다시 입력해주세요."
        case .registerFailure(let message):
            return "회원가입에 실패했습니다. 다시 시도해주세요. \n \(message)"
        case .registerSuccess:
            return "회원가입에 성공했습니다. 로그인 해주세요."
        }
    }
}

enum PrayerAlert: Identifiable {
    case categoryNotSelected
    case fieldEmpty(fieldName: String)
    case deleteFailure(message: String)
    case writeError(message: String)
    
    var id: Int {
        switch self {
        case .categoryNotSelected: return 0
        case .fieldEmpty: return 1
        case .deleteFailure: return 2
        case .writeError: return 3
        }
    }
    
    var title: String {
        switch self {
        case .categoryNotSelected:
            return "카테고리를 선택해 주세요."
        case .fieldEmpty:
            return "입력 오류"
        case .deleteFailure:
            return "삭제 실패"
        case .writeError:
            return "기도 작성 실패"
        }
    }
    
    var message: String {
        switch self {
        case .categoryNotSelected:
            return "카테고리를 선택해 주세요."
        case .fieldEmpty(let message):
            return "\(message)을 입력해주세요."
        case .deleteFailure(let message):
            return "삭제 실패했습니다. 다시 시도해주세요. \n \(message)"
        case .writeError(let message):
            return message
        }
    }
}
