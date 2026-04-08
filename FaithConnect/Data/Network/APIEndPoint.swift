//
//  APIEndPoint.swift
//  FaithConnect
//
//  Created by Apple on 12/29/25.
//

import Foundation


// MARK: - 서버 주소 (dev / release)
enum ServerEnvironment: String {
    case dev
    case release

    static var current: ServerEnvironment {
        let value = Bundle.main.infoDictionary?["ServerEnvironment"] as? String
        return ServerEnvironment(rawValue: value ?? "") ?? .release
    }

    var baseURL: String {
        switch self {
        case .dev:
            return "http://localhost:8080"
        case .release:
            return "https://faith-connect.net"
        }
    }
}


// MARK: - API 경로 (mock / production)
enum APIEnvironment: String {
    case mock
    case production

    static var current: APIEnvironment {
        let value = Bundle.main.infoDictionary?["APIEnvironment"] as? String
        return APIEnvironment(rawValue: value ?? "") ?? .production
    }
}

enum APIEndpoint {
    // MARK: - Auth
    case signup
    case login
    case logout
    case fetchMyInfo
    case findID
    case changePassword
    case passwordReset
    case passwordResetConfirm
    case deleteAccount
    case emailVerificationRequest
    case emailVerificationConfirm
    // MARK: - Prayer
    case categories
    case prayers
    case prayerDetail(id: Int)
    case responses
    case responseDetail(id: Int)
    case myRequests
    case myPrayers
    case reportPrayer(id: Int)
    case reportPrayerResponse(id: Int)
    case blockUser(userId: Int)
    case replies(responseId: Int)
    // MARK: - Push
    case pushToken
    case pushTest
    case pushTestMock
    // MARK: - Inquiry
    case inquiry
    // MARK: - Token
    case refreshToken
    
    private var baseURL: String {
        ServerEnvironment.current.baseURL
    }
    
    private var basePath: String {
        switch APIEnvironment.current {
        case .mock:
            return "/api/prayer/mock"
        case .production:
            return "/api/prayer"
        }
    }
    
    var path: String {
        switch self {
        case .signup:
            return "\(basePath)/signup"
        case .login:
            return "\(basePath)/login"
        case .logout:
            return "\(basePath)/logout"
        case .fetchMyInfo:
            return "\(basePath)/me"
        case .findID:
            return "\(basePath)/find-email"
        case .changePassword:
            return "\(basePath)/change-password"
        case .passwordReset:
            return "\(basePath)/password-reset/request"
        case .passwordResetConfirm:
            return "\(basePath)/password-reset/confirm"
        case .deleteAccount:
            return "\(basePath)/me"
        case .emailVerificationRequest:
            return "\(basePath)/email-verification/request"
        case .emailVerificationConfirm:
            return "\(basePath)/email-verification/confirm"
        case .categories:
            return "\(basePath)/categories"
        case .prayers:
            return "\(basePath)/requests"
        case .prayerDetail(let id):
            return "\(basePath)/requests/\(id)"
        case .responses:
            return "\(basePath)/responses"
        case .responseDetail(let id):
            return "\(basePath)/responses/\(id)"
        case .myRequests:
            return "\(basePath)/my-requests"
        case .myPrayers:
            return "\(basePath)/my-prayers"
        case .pushToken:
            return "\(basePath)/push-token"
        case .pushTest:
            return "\(basePath)/push/test"
        case .pushTestMock:
            return "\(basePath)/push/test/mock"
        case .inquiry:
            return "\(basePath)/inquiry"
        case .reportPrayer(let id):
            return "\(basePath)/requests/\(id)/report"
        case .reportPrayerResponse(let id):
            return "\(basePath)/responses/\(id)/report"
        case .blockUser(let userId):
            return "\(basePath)/users/\(userId)/block"
        case .replies(let responseId):
            return "\(basePath)/responses/\(responseId)/replies"
        case .refreshToken:
            return "\(basePath)/refresh-token"
        }
    }
    
    var urlString: String {
        self.baseURL + path
    }
}
