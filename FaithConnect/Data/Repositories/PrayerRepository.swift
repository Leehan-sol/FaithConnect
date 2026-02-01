//
//  PrayerRepository.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/24.
//

import Foundation
import Combine

class PrayerRepository: ObservableObject, PrayerRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func loadCategories() async throws -> [CategoryResponse] {
        return try await apiClient.loadCategories()
    }
    
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerListResponse {
        return try await apiClient.loadPrayers(categoryID: categoryID, page: page)
    }
    
    func loadPrayerDetail(prayerRequestID: Int) async throws -> PrayerDetailResponse {
        return try await apiClient.loadPrayerDetail(prayerRequestID: prayerRequestID)
    }
    
    func writePrayer(categoryID: Int, title: String, content: String) async throws -> PrayerWriteResponse {
        return try await apiClient.writePrayer(categoryID: categoryID, title: title, content: content)
    }
    
    func deletePrayer(prayerRequestId: Int) async throws {
        try await apiClient.deletePrayer(prayerRequestId: prayerRequestId)
    }
    
    func writePrayerResponse(prayerRequsetID: Int, message: String) async throws -> DetailResponseItem {
        return try await apiClient.writePrayerResponse(prayerRequsetID: prayerRequsetID, message: message)
    }
    
    func deletePrayerResponse(responseID: Int) async throws {
        return try await apiClient.deletePrayerResponse(responseID: responseID)
    }
    
    func loadWrittenPrayers(page: Int) async throws -> PrayerListResponse {
        return try await apiClient.loadWrittenPrayers(page: page)
    }
    
    func loadParticipatedPrayers(page: Int) async throws -> MyResponseList {
        return try await apiClient.loadParticipatedPrayers(page: page)
    }
    
}
