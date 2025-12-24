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
    case serverMessage(String)
    case failureLogin
    case failureFindID
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "유효하지 않은 URL입니다."
        case .decodingError: return "데이터 형식을 알 수 없습니다."
        case .httpError(let code): return "네트워크 오류 발생 (Status: \(code))."
        case .serverMessage(let msg): return msg
        case .failureLogin: return "로그인에 실패했습니다. 다시 시도해주세요."
        case .failureFindID: return "아이디를 찾을 수 없습니다. 다시 시도해주세요."
        }
    }
}
