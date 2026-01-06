//
//  APIErrorCode.swift
//  FaithConnect
//
//  Created by Apple on 1/5/26.
//

enum APIErrorCode: Int, Decodable {
    // MARK: - Auth
    case expiredAccessToken = 50001 // Access Token이 만료되었습니다.
    case userNotFound = 51001 // 사용자를 찾을 수 없습니다.
    case userExistByEmail = 51002 // 해당 이메일의 사용자가 있습니다.
    case passwordMismatch = 51003 // 비밀번호가 일치하지 않습니다.
    case invalidUserInformation = 51004 // 입력하신 정보가 올바르지 않습니다.
    
    // MARK: - Prayer
    case categoryNotFound = 52001 // 기도 카테고리를 찾을 수 없습니다.
    case prayerNotFound = 52002 // 기도 제목을 찾을 수 없습니다.
    case onlyAuthorCanDeletePrayer = 52003 // 본인이 작성한 기도제목만 삭제할 수 있습니다.
    
    // MARK: - Validation
    case invalidRequestParameter = 54001 // 입력값이 올바르지 않습니다.
    case dataIntegrityViolation = 54002 // 데이터 무결성 오류가 발생했습니다.
    
    // MARK: - Common
    case unknown = 59999
}
