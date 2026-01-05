//
//  APIError.swift
//  FaithConnect
//
//  Created by Apple on 12/24/25.
//

enum APIError: Error {
    case invalidURL
    case decodingError
    case httpError(statusCode: Int)
    case emptyResponse
    case serverMessage(code: APIErrorCode)
}

extension APIError {
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .decodingError:
            return "데이터 형식을 알 수 없습니다."
        case .httpError(let code):
            return "네트워크 오류 발생 (Status: \(code))."
        case .emptyResponse:
            return "네트워크 응답이 없습니다."
        case .serverMessage(let code):
            switch code {
            case .userNotFoundByEmail:
                return "해당 이메일의 사용자가 없습니다."
            case .passwordMismatch:
                return "비밀번호가 일치하지 않습니다."
            case .invalidUserInformation:
                return "입력하신 정보가 올바르지 않습니다."
            case .invalidRequestParameter:
                return "입력값이 올바르지 않습니다."
            case .dataIntegrityViolation:
                return "데이터 무결성 오류가 발생했습니다."
            case .unknown:
                return "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            }
        }
    }
}

