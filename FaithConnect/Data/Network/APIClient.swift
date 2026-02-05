//
//  apiClient.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import Foundation

// MARK: - Protocol
protocol APIClientProtocol {
    var hasToken: Bool { get }
    // Auth
    func signUp(memberID: Int, name: String, email: String, password: String, confirmPassword: String) async throws
    func login(email: String, password: String) async throws
    func logout() async throws
    func fetchMyInfo() async throws -> User
    func findID(memberID: Int, name: String) async throws -> String
    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws
    
    // Prayer
    func loadCategories() async throws -> [CategoryResponse]
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerListResponse
    func loadPrayerDetail(prayerRequestID: Int) async throws -> PrayerDetailResponse
    func writePrayer(categoryID: Int, title: String, content: String) async throws -> PrayerWriteResponse
    func deletePrayer(prayerRequestId: Int) async throws
    func writePrayerResponse(prayerRequsetID: Int, message: String) async throws -> DetailResponseItem
    func deletePrayerResponse(responseID: Int) async throws
    func loadWrittenPrayers(page: Int) async throws -> PrayerListResponse
    func loadParticipatedPrayers(page: Int) async throws -> MyResponseList
}

// MARK: - APIClient
final class APIClient: APIClientProtocol {
    private let tokenStorage: TokenStorageProtocol
    @MainActor private var refreshTask: Task<Void, Error>?
    
    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    var hasToken: Bool {
        if let refreshToken = tokenStorage.refreshToken, !refreshToken.isEmpty {
            return true
        }
        return false
    }
}

// MARK: - Network
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
        
        return try await performRequest(request: request,
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
        return try await performRequest(request: request,
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
        return try await performRequest(request: request,
                                        auth: auth)
    }
    
    private func performRequest<Response: Decodable>(
        request: URLRequest,
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

        // 토큰만료
        if httpResponse.statusCode == 401 {
            if auth == .required, tokenStorage.accessToken != nil {
                if isRetry {
                    await handleSessionExpiration()
                    throw APIError.serverMessage(code: .expiredAccessToken)
                }
                
                do {
                    try await refreshAccessToken()
                    var retryRequest = request
                    if let newToken = tokenStorage.accessToken {
                        retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                    }
                    
                    return try await performRequest(request: retryRequest,
                                                    isRetry: true,
                                                    auth: auth)
                } catch {
                    throw error
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
    
    private func parseError<T>(from data: Data, statusCode: Int) throws -> T {
        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            throw APIError.serverMessage(code: errorResponse.errorCode)
        }
        throw APIError.httpError(statusCode: statusCode)
    }
    
}

// MARK: - Auth
extension APIClient {
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
    
    func login(email: String, password: String) async throws {
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
    }
    
    func logout() async throws {
        let urlString = APIEndpoint.logout.urlString
        
        let apiResponse: LogoutResponse = try await post(urlString: urlString,
                                                         requestBody: EmptyRequest())
        
        guard apiResponse.success == true else {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        }
        
        await MainActor.run {
            tokenStorage.clear()
        }
    }
    
    func fetchMyInfo() async throws -> User {
        let urlString = APIEndpoint.fetchMyInfo.urlString
        
        let apiResponse: FetchMyInfoResponse = try await get(path: urlString)
        
        let user = User(name: apiResponse.name,
                        email: apiResponse.email)
        
        return user
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
    
}

// MARK: - Prayer
extension APIClient {
    func loadCategories() async throws -> [CategoryResponse] {
        let urlString = APIEndpoint.categories.urlString
        
        let apiResponse: [CategoryResponse] = try await get(path: urlString)
        
        return apiResponse
    }
    
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerListResponse {
        let urlString = APIEndpoint.prayers.urlString
        
        let apiResponse: PrayerListResponse = try await get(path: urlString,
                                                            queryItems: [
                                                                URLQueryItem(name: "categoryId", value: "\(categoryID)"),
                                                                URLQueryItem(name: "page", value: "\(page)")
                                                            ])
        
        return apiResponse
    }
    
    func loadPrayerDetail(prayerRequestID: Int) async throws -> PrayerDetailResponse {
        let urlString = APIEndpoint.prayerDetail(id: prayerRequestID).urlString
        
        let apiResponse: PrayerDetailResponse = try await get(path: urlString)
        
        return apiResponse
    }
    
    func writePrayer(categoryID: Int, title: String, content: String) async throws -> PrayerWriteResponse {
        let urlString = APIEndpoint.prayers.urlString
        
        let requestBody = PrayerWriteRequest(
            categoryId: categoryID,
            title: title,
            content: content
        )
        
        let apiResponse: PrayerWriteResponse = try await post(urlString: urlString,
                                                              requestBody: requestBody)
        
        return apiResponse
    }
    
    func deletePrayer(prayerRequestId: Int) async throws {
        let urlString = APIEndpoint.prayerDetail(id: prayerRequestId).urlString
        
        let apiResponse: PrayerDeleteResponse = try await delete(path: urlString)
        
        if apiResponse.success != true {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        }
    }
    
    func writePrayerResponse(prayerRequsetID: Int, message: String) async throws -> DetailResponseItem {
        let urlString = APIEndpoint.responses.urlString
        
        let requestBody = PrayerResponseWriteRequest(prayerRequestId: prayerRequsetID,
                                                     message: message)
        
        let apiResponse: DetailResponseItem = try await post(urlString: urlString,
                                                             requestBody: requestBody)
        return apiResponse
    }
    
    func deletePrayerResponse(responseID: Int) async throws {
        let urlString = APIEndpoint.responseDetail(id: responseID).urlString
        
        let apiResponse: PrayerDeleteResponse = try await delete(path: urlString)
        
        if apiResponse.success != true {
            let code = apiResponse.errorCode ?? .unknown
            throw APIError.serverMessage(code: code)
        }
    }
    
    func loadWrittenPrayers(page: Int) async throws -> PrayerListResponse {
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
        
        return apiResponse
    }
    
    func loadParticipatedPrayers(page: Int) async throws -> MyResponseList {
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
        
        return apiResponse
    }
}

// MARK: - Token
extension APIClient {
    private func refreshAccessToken() async throws {
        print("refreshAccessToken")
        if let ongoingTask = await MainActor.run(body: { return refreshTask }) {
            return try await ongoingTask.value
        }
        
        let task = Task<Void, Error> {
            defer {
                Task { @MainActor in refreshTask = nil }
            }
            let urlString = APIEndpoint.refreshToken.urlString
            guard let url = URL(string: urlString) else { throw APIError.invalidURL }
            
            guard let refreshToken = tokenStorage.refreshToken else {
                await handleSessionExpiration()
                throw APIError.serverMessage(code: .refreshTokenNotFound)
            }
            
            let requestBody = AccessTokenRequest(refreshToken: refreshToken)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.serverMessage(code: .unknown)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                        throw APIError.serverMessage(code: errorResponse.errorCode)
                    }
                    throw APIError.httpError(statusCode: httpResponse.statusCode)
                }
                
                let apiResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                
                guard !apiResponse.accessToken.isEmpty, !apiResponse.refreshToken.isEmpty else {
                    throw APIError.serverMessage(code: .unknown)
                }
                
                await MainActor.run {
                    tokenStorage.save(accessToken: apiResponse.accessToken,
                                           refreshToken: apiResponse.refreshToken)
                }
                
            } catch {
                // refresh Token 만료
                await handleSessionExpiration()
                throw error
            }
        }
        await MainActor.run { self.refreshTask = task }
        return try await task.value
    }
    
    private func handleSessionExpiration() async {
        tokenStorage.clear()
        await MainActor.run {
            NotificationCenter.default.post(name: .logoutRequired, object: nil)
        }
    }
}
