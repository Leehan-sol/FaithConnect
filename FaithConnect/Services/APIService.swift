//
//  APIService.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

// MARK: - Protocol
protocol APIServiceProtocol {
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws -> Void
    func login(email: String, password: String) async throws -> LoginResponse
    func findID(memberID: Int, name: String) async throws -> String
    func loadCategories() async throws -> [PrayerCategory]
    func loadPrayers(categoryId: Int, page: Int) async throws -> PrayerPage
    func writePrayer(categoryId: Int, title: String, content: String) async throws -> Prayer
}

// MARK: - APIService
struct APIService: APIServiceProtocol {
    private let baseURL = "http://prayer-app.duckdns.org/dev"
    
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
        
        let apiResponse = try JSONDecoder().decode(SignUpResponse.self,
                                                   from: data)
        
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
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self,
                                                     from: data)
        
        guard !loginResponse.accessToken.isEmpty,
              !loginResponse.refreshToken.isEmpty else {
            throw APIError.failureLogin
        }
        
        // TODO: - API 변경 후 User 정보 반환하도록 수정 필요
        return loginResponse
    }
    
    
    func findID(memberID: Int, name: String) async throws -> String {
        let urlString = baseURL + "/api/prayer/mock/find-email"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let requestBody = FindIDRequest(name: name,
                                        churchMemberId: memberID)
        
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
        
        let apiResponse = try JSONDecoder().decode(FindIDResponse.self,
                                                   from: data)
        
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
            let categoryResponses = try decoder.decode([CategoryResponse].self,
                                                       from: data)
            
            let prayerCategories = categoryResponses.map { response in
                PrayerCategory(id: response.categoryId,
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
    
    func loadPrayers(categoryId: Int, page: Int) async throws -> PrayerPage {
        var components = URLComponents(string: baseURL + "/api/prayer/mock/requests")
        components?.queryItems = [
            URLQueryItem(name: "categoryId", value: "\(categoryId)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
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
            let prayerResponse = try decoder.decode(PrayerListResponse.self,
                                                    from: data)
            
            let prayerPage = PrayerPage(prayers: prayerResponse.prayerRequests.map { Prayer(from: $0) },
                                        currentPage: prayerResponse.currentPage,
                                        hasNext: prayerResponse.hasNext)
            return prayerPage
        } catch let decodingError as DecodingError {
            print("기도 목록 디코딩 실패: \(decodingError)")
            throw APIError.decodingError
        } catch {
            print("기도 목록 로드 중 에러 발생: \(error)")
            throw error
        }
    }
    
    func writePrayer(categoryId: Int, title: String, content: String) async throws -> Prayer {
        let urlString = baseURL + "/api/prayer/mock/requests"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let requestBody = PrayerWriteRequest(
            categoryId: categoryId,
            title: title,
            content: content
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
        
        let result = try JSONDecoder().decode(PrayerWriteResponse.self,
                                                from: data)
        
        let prayer = Prayer(id: result.prayerRequestId,
                            userId: result.prayerUserId,
                            userName: result.prayerUserName,
                            categoryId: result.categoryId,
                            categoryName: result.categoryName,
                            title: result.title,
                            content: result.content,
                            createdAt: result.createdAt,
                            participationCount: result.participationCount,
                            responses: [],
                            hasParticipated: false)
        return prayer
    }
}
