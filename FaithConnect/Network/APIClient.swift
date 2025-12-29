//
//  apiClient.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

// MARK: - Protocol
protocol APIClientProtocol {
    // Auth
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws -> Void
    func login(email: String, password: String) async throws -> LoginResponse
    func findID(memberID: Int, name: String) async throws -> String
    // Prayer
    func loadCategories() async throws -> [PrayerCategory]
    func loadPrayers(categoryId: Int, page: Int) async throws -> PrayerPage
    func loadPrayerDetail(prayerRequestId: Int) async throws -> Prayer
    func writePrayer(categoryId: Int, title: String, content: String) async throws -> Prayer
    func deletePrayer(prayerRequestId: Int) async throws
    func writePrayerResponse(prayerRequsetId: Int, message: String) async throws -> PrayerResponse
    func deletePrayerResponse(prayerRequestId: Int) async throws
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage
}

// MARK: - APIClient
struct APIClient: APIClientProtocol {
    private let baseURL = "http://prayer-app.duckdns.org/dev"
    
    private func post<Request: Encodable, Response: Decodable>(
        urlString: String,
        requestBody: Request
    ) async throws -> Response {
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.httpError(statusCode: statusCode)
        }
        
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch _ as DecodingError {
            throw APIError.decodingError
        }
    }
    
    private func get<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> Response {
        
        var components = URLComponents(string: path)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.httpError(statusCode: statusCode)
        }
        
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch _ as DecodingError {
            throw APIError.decodingError
        }
    }
    
    // MARK: - Auth
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws -> Void {
        let urlString = APIEndpoint.signup.urlString
        
        let requestBody = SignUpRequest(
            churchMemberId: memberID,
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        let apiResponse: SignUpResponse = try await post(urlString: urlString,
                                         requestBody: requestBody)
        
        if !apiResponse.success {
            throw APIError.serverMessage(apiResponse.message)
        }
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let urlString = APIEndpoint.login.urlString
        
        let requestBody = LoginRequest(
            email: email,
            password: password
        )
        
        let apiResponse: LoginResponse = try await post(urlString: urlString,
                                         requestBody: requestBody)
        
        guard !apiResponse.accessToken.isEmpty,
              !apiResponse.refreshToken.isEmpty else {
            throw APIError.failureLogin
        }

        return apiResponse
    }
    
    
    func findID(memberID: Int, name: String) async throws -> String {
        let urlString = APIEndpoint.findID.urlString
        
        let requestBody = FindIDRequest(name: name,
                                        churchMemberId: memberID)
        
        let apiResponse: FindIDResponse = try await post(urlString: urlString,
                                         requestBody: requestBody)
        
        if apiResponse.success != true {
            throw APIError.failureFindID
        } else {
            return apiResponse.email
        }
    }
    
    // MARK: - Prayer
    func loadCategories() async throws -> [PrayerCategory] {
        let urlString = APIEndpoint.categories.urlString
        
        let apiResponse: [CategoryResponse] = try await get(path: urlString)
        
        let category = apiResponse.map { response in
            PrayerCategory(id: response.categoryId,
                           categoryCode: response.categoryCode,
                           categoryName: response.categoryName)
        }
        
        print("서버에서 받은 카테고리:", category.count)
        category.forEach { category in
            print("""
                      ─────────────
                      id: \(category.id)
                      name: \(category.categoryName)
                      """)
        }
        
        return category
    }
    
    func loadPrayers(categoryId: Int, page: Int) async throws -> PrayerPage {
        let urlString = APIEndpoint.prayers.urlString
        
        let apiResponse: PrayerListResponse = try await get(
            path: urlString,
            queryItems: [
                URLQueryItem(name: "categoryId", value: "\(categoryId)"),
                URLQueryItem(name: "page", value: "\(page)")
            ])
        
        print("서버에서 받은 기도:", apiResponse.prayerRequests.count)
        apiResponse.prayerRequests.forEach { prayer in
            print("""
                  ─────────────
                  id: \(prayer.prayerRequestId)
                  title: \(prayer.title)
                  categoryId: \(prayer.categoryId)
                  """)
        }
        
        return PrayerPage(prayers: apiResponse.prayerRequests.map { Prayer(from: $0) },
                          currentPage: apiResponse.currentPage,
                          hasNext: apiResponse.hasNext)
    }
    
    func loadPrayerDetail(prayerRequestId: Int) async throws -> Prayer {
        let urlString = APIEndpoint.prayerDetail(id: prayerRequestId).urlString
        
        let apiResponse: PrayerDetailResponse = try await get(path: urlString)
    
        return Prayer(from: apiResponse)
    }
    
    func writePrayer(categoryId: Int, title: String, content: String) async throws -> Prayer {
        let urlString = APIEndpoint.prayers.urlString
        
        let requestBody = PrayerWriteRequest(
            categoryId: categoryId,
            title: title,
            content: content
        )
        
        let apiResponse: PrayerWriteResponse = try await post(urlString: urlString,
                                         requestBody: requestBody)
        
        return Prayer(from: apiResponse)
    }
    
    func deletePrayer(prayerRequestId: Int) async throws {
        
    }
    
    func writePrayerResponse(prayerRequsetId: Int, message: String) async throws -> PrayerResponse {
        let urlString = APIEndpoint.responses.urlString
        
        let requestBody = PrayerResponseWriteRequest(prayerRequestId: prayerRequsetId,
                                                     message: message)
        
        let apiResponse: DetailResponseItem = try await post(urlString: urlString,
                                         requestBody: requestBody)
        
        return PrayerResponse(from: apiResponse)
    }
    
    func deletePrayerResponse(prayerRequestId: Int) async throws {
        
    }
    
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        let urlString = APIEndpoint.myRequests.urlString
        
        let apiResponse: PrayerListResponse = try await get(path: urlString,
                                        queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        
        print("서버에서 받은 내 기도:", apiResponse.prayerRequests.count)
        apiResponse.prayerRequests.forEach { prayer in
            print("""
                  ─────────────
                  id: \(prayer.prayerRequestId)
                  title: \(prayer.title)
                  categoryId: \(prayer.categoryId)
                  """)
        }
        
        return PrayerPage(prayers: apiResponse.prayerRequests.map { Prayer(from: $0) },
                          currentPage: apiResponse.currentPage,
                          hasNext: apiResponse.hasNext)
    }
    
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage {
        let urlString = APIEndpoint.myPrayers.urlString
        
        let apiResponse: MyResponseList = try await get(path: urlString,
                                        queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        
        print("서버에서 받은 내 응답:", apiResponse.responses.count)
        apiResponse.responses.forEach { response in
            print("""
                  ─────────────
                  id: \(response.prayerResponseId)
                  title: \(response.message)
                  categoryId: \(response.categoryId)
                  """)
        }
        
        return MyResponsePage(responses: apiResponse.responses.map { MyResponse(from: $0) },
                              currentPage: apiResponse.currentPage,
                              hasNext: apiResponse.hasNext)
    }
    
    
}
