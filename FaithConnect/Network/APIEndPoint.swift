//
//  APIEndPoint.swift
//  FaithConnect
//
//  Created by Apple on 12/29/25.
//

enum APIEndpoint {
    static let baseURL = "http://prayer-app.duckdns.org/dev"
    
    case signup
    case login
    case findID
    case categories
    case prayers
    case prayerDetail(id: Int)
    case responses
    case myRequests
    case myPrayers
    
    var path: String {
        switch self {
        case .signup: return "/api/prayer/mock/signup"
        case .login: return "/api/prayer/mock/login"
        case .findID: return "/api/prayer/mock/find-email"
        case .categories: return "/api/prayer/mock/categories"
        case .prayers: return "/api/prayer/mock/requests"
        case .prayerDetail(let id): return "/api/prayer/mock/requests/\(id)"
        case .responses: return "/api/prayer/mock/responses"
        case .myRequests: return "/api/prayer/mock/my-requests"
        case .myPrayers: return "/api/prayer/mock/my-prayers"
        }
    }
    
    var urlString: String {
        Self.baseURL + path
    }
}
