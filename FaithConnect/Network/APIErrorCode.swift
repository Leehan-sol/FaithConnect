//
//  APIErrorCode.swift
//  FaithConnect
//
//  Created by Apple on 1/5/26.
//

enum APIErrorCode: Int, Decodable {
    // MARK: - Auth
    case userNotFoundByEmail = 51002 // 해당 이메일의 사용자가 없습니다.
    case passwordMismatch = 51003 // 비밀번호가 일치하지 않습니다.
    case invalidUserInformation = 51004 // 입력하신 정보가 올바르지 않습니다.
    
    // MARK: - Validation
    case invalidRequestParameter = 54001 // 입력값이 올바르지 않습니다.
    case dataIntegrityViolation = 54002 // 데이터 무결성 오류가 발생했습니다.
    
    // MARK: - Common
    case unknown = 59999
}
