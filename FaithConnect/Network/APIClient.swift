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
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws
    func login(email: String, password: String) async throws -> LoginResponse
    func logout() async throws
    func findID(memberID: Int, name: String) async throws -> String
    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws
    
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
    private let tokenStorage: TokenStorageProtocol
    
    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Auth
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws {
        let urlString = APIEndpoint.signup.urlString
        
        let requestBody = SignUpRequest(
            churchMemberId: memberID,
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        let apiResponse: SignUpResponse = try await post(urlString: urlString,
                                                         requestBody: requestBody,
                                                         auth: .none)
        
        guard apiResponse.success == true else {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        }
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let urlString = APIEndpoint.login.urlString
        print("\(urlString)")
        let requestBody = LoginRequest(
            email: email,
            password: password
        )
        
        let apiResponse: LoginResponse = try await post(urlString: urlString,
                                                        requestBody: requestBody,
                                                        auth: .none)
        
        guard !apiResponse.accessToken.isEmpty,
              !apiResponse.refreshToken.isEmpty else {
            let errorCode = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: errorCode)
        }
        
        await MainActor.run {
            tokenStorage.save(
                accessToken: apiResponse.accessToken,
                refreshToken: apiResponse.refreshToken
            )
        }
        
        return apiResponse
    }
    
    func logout() async throws {
        let urlString = APIEndpoint.logout.urlString
        
        let apiResponse: LogoutResponse = try await post(urlString: urlString,
                                                         requestBody: EmptyRequest())
        
        guard apiResponse.success == true else {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        }
    }
    
    func findID(memberID: Int, name: String) async throws -> String {
        let urlString = APIEndpoint.findID.urlString
        
        let requestBody = FindIDRequest(name: name,
                                        churchMemberId: memberID)
        
        let apiResponse: FindIDResponse = try await post(urlString: urlString,
                                                         requestBody: requestBody,
                                                         auth: .none)
        
        if apiResponse.success != true {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        } else {
            return apiResponse.email
        }
    }
    
    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws {
        let urlString = APIEndpoint.changePassword.urlString
        
        let requestBody = ChangePasswordRequest(name: name,
                                                churchMemberId: id,
                                                email: email,
                                                newPassword: newPassword)
        
        let apiResponse: ChangePasswordResponse = try await post(urlString: urlString,
                                                                 requestBody: requestBody,
                                                                 auth: .none)
        
        if apiResponse.success != true {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
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
        
        print("카테고리:", category.count)
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
        
        print("기도:", apiResponse.prayerRequests.count)
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
        let urlString = APIEndpoint.prayerDetail(id: prayerRequestId).urlString
        
        let apiResponse: PrayerDeleteResponse = try await delete(path: urlString)
        
        if apiResponse.success != true {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        }
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
        let urlString = APIEndpoint.responseDetail(id: prayerRequestId).urlString
        
        let apiResponse: PrayerDeleteResponse = try await delete(path: urlString)
        
        if apiResponse.success != true {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        }
    }
    
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        let urlString = APIEndpoint.myRequests.urlString
        
        let apiResponse: PrayerListResponse = try await get(path: urlString,
                                                            queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        
        print("내 기도:", apiResponse.prayerRequests.count)
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
        
        print("내 응답:", apiResponse.responses.count)
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

// MARK: - Extension
extension APIClient {
    private func post<Req: Encodable, Res: Decodable>(
        urlString: String,
        requestBody: Req? = nil,
        auth: AuthRequirement = .required
    ) async throws -> Res {
        
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let body = requestBody, !(body is EmptyRequest) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return try await performRequest(request,
                                        auth: auth)
    }
    
    private func get<Res: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        auth: AuthRequirement = .required
    ) async throws -> Res {
        var components = URLComponents(string: path)
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        
        let request = URLRequest(url: url)
        return try await performRequest(request,
                                        auth: auth)
    }
    
    private func delete<Res: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        auth: AuthRequirement = .required
    ) async throws -> Res {
        var components = URLComponents(string: path)
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return try await performRequest(request,
                                        auth: auth)
    }
    
    private func performRequest<Response: Decodable>(
        _ request: URLRequest,
        isRetry: Bool = false,
        auth: AuthRequirement = .required
    ) async throws -> Response {
        
        var request = request
        
        if auth == .required, let token = tokenStorage.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverMessage(code: .unknown)
        }
        
        if httpResponse.statusCode == 401 {
            // 토큰만료
            if auth == .required, tokenStorage.accessToken != nil {
                if isRetry {
                    handleSessionExpiration()
                    throw APIError.serverMessage(code: .expiredAccessToken)
                }
                
                let success = await refreshAccessToken()
                if success {
                    return try await performRequest(request,
                                                    isRetry: true,
                                                    auth: auth)
                } else {
                    handleSessionExpiration()
                    throw APIError.serverMessage(code: .expiredAccessToken)
                }
            }
            
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverMessage(code: errorResponse.errorCode)
            }
            
            throw APIError.serverMessage(code: .unknown)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverMessage(code: errorResponse.errorCode)
            }
            
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        if data.isEmpty, Response.self == EmptyResponse.self {
            return try JSONDecoder().decode(Response.self, from: "{}".data(using: .utf8)!)
        }
        
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    
    private func refreshAccessToken() async -> Bool {
        guard let refreshToken = tokenStorage.refreshToken else { return false }
        // TODO: - RefreshToken으로 AccessToken 생성하는 API 호출
        return true
    }
    
    private func handleSessionExpiration() {
        // TODO: - NotificationCenter를 통해 UserSession에 알림, 로그아웃
    }
}
