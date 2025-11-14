//
//  APIService.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

protocol APIServiceProtocol {
    func signUp(memberID: String, name: String, email: String, password: String, confirmPassword: String) async throws -> Void
    func login(email: String, password: String) async throws -> Void
}

enum APIError: Error {
    case invalidURL
    case decodingError
    case httpError(statusCode: Int)
    case serverMessage(String)
    case failureLogin
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "유효하지 않은 URL입니다."
        case .decodingError: return "데이터 형식을 알 수 없습니다."
        case .httpError(let code): return "네트워크 오류 발생 (Status: \(code))."
        case .serverMessage(let msg): return msg
        case .failureLogin: return "로그인에 실패했습니다. 다시 시도해주세요."
        }
    }
}

struct APIService: APIServiceProtocol {
    let baseURL = "https://manchunggrouproom.duckdns.org/dev"
    
    func signUp(memberID: String, name: String, email: String, password: String, confirmPassword: String) async throws -> Void {
        let urlString = baseURL + "/api/prayer/mock/signup"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let requestBody = SignUpRequest(
            churchMemberId: memberID,
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.httpError(statusCode: statusCode)
        }
        
        let apiResponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
        
        if !apiResponse.success {
            throw APIError.serverMessage(apiResponse.message)
        }
    }
    
    func login(email: String, password: String) async throws -> Void {
        let urlString = baseURL + "/api/prayer/mock/login"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let requestBody = LoginRequest(
            email: email,
            password: password
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.httpError(statusCode: statusCode)
        }
        
        let apiResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        if apiResponse.accessToken == "" || apiResponse.refreshToken == "" {
            throw APIError.failureLogin
        }
    }
    
}
