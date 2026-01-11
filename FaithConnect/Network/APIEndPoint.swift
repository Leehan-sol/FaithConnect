//
//  APIEndPoint.swift
//  FaithConnect
//
//  Created by Apple on 12/29/25.
//

import Foundation

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
    // MARK: - Prayer
    case categories
    case prayers
    case prayerDetail(id: Int)
    case responses
    case responseDetail(id: Int)
    case myRequests
    case myPrayers
    // MARK: - Token
    case refreshToken
    
    private static let baseURL = "http://prayer-app.duckdns.org/dev"
    
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
        case .refreshToken:
            return "\(basePath)/refresh-token"
        }
    }
    
    var urlString: String {
        Self.baseURL + path
    }
}
