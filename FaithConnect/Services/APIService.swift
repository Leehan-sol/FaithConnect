//
//  APIService.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

protocol APIServiceProtocol {
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws -> Void
    func login(email: String, password: String) async throws -> LoginResponse
    func findID(memberID: Int, name: String) async throws -> String
    func loadCategories() async throws -> [PrayerCategory]
    func loadPrayers(selectedCategory: Int, page: Int) async throws -> PrayerResponse
}

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

struct APIService: APIServiceProtocol {
//    private let baseURL = "http://prayer-app.duckdns.org/dev"
    let baseURL = "http://prayer-app.duckdns.org/dev"

    
    // MARK: - Auth
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws -> Void {
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
    
    func login(email: String, password: String) async throws -> LoginResponse {
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
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        guard !loginResponse.accessToken.isEmpty,
              !loginResponse.refreshToken.isEmpty else {
            throw APIError.failureLogin
        }
        
        return loginResponse
    }
    
    
    func findID(memberID: Int, name: String) async throws -> String {
        let urlString = baseURL + "/api/prayer/mock/find-email"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let requestBody = FindIDRequest(name: name, churchMemberId: memberID)
        
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
        
        let apiResponse = try JSONDecoder().decode(FindIDResponse.self, from: data)
        
        if apiResponse.success != true {
            throw APIError.failureFindID
        } else {
            return apiResponse.email
        }
    }
    
    // MARK: - Prayer
    func loadCategories() async throws -> [PrayerCategory] {
        let urlString = baseURL + "/api/prayer/mock/categories"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                throw APIError.httpError(statusCode: statusCode)
            }
            
            let decoder = JSONDecoder()
            let categoryResponses = try decoder.decode([CategoryResponse].self, from: data)
        
            let prayerCategories = categoryResponses.map { response in
                PrayerCategory(categoryId: response.categoryId,
                               categoryCode: response.categoryCode,
                               categoryName: response.categoryName)
            }
            
            return prayerCategories
            
        } catch let decodingError as DecodingError {
            print("카테고리 디코딩 실패: \(decodingError)")
            throw APIError.decodingError
        } catch {
            print("카테고리 로드 중 에러 발생: \(error)")
            throw error
        }
    }

    func loadPrayers(selectedCategory: Int, page: Int) async throws -> PrayerResponse {
        let urlString = baseURL + "/api/prayer/mock/requests?page=\(page)&categoryId=\(selectedCategory)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.httpError(statusCode: statusCode)
        }
        
        do {
            let decoded = try JSONDecoder().decode(PrayerResponse.self, from: data)
            return decoded
        } catch {
            print("디코딩 실패: \(error)")
            throw APIError.decodingError
        }
    }



}
