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
    
    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> PrayerDetailResponse {
        return try await apiClient.updatePrayer(prayerRequestId: prayerRequestId, 
                                                categoryID: categoryID, 
                                                title: title,
                                                content: content)
    }

    func deletePrayer(prayerRequestId: Int) async throws {
        try await apiClient.deletePrayer(prayerRequestId: prayerRequestId)
    }
    
    func writePrayerResponse(prayerRequestID: Int, message: String) async throws -> DetailResponseItem {
        return try await apiClient.writePrayerResponse(prayerRequestID: prayerRequestID, 
                                                       message: message)
    }
    
    func updatePrayerResponse(responseID: Int, message: String) async throws -> DetailResponseItem {
        return try await apiClient.updatePrayerResponse(responseID: responseID, 
                                                        message: message)
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

    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        try await apiClient.reportPrayer(prayerRequestId: prayerRequestId, reasonType: reasonType, reasonDetail: reasonDetail)
    }

    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        try await apiClient.reportPrayerResponse(prayerResponseId: prayerResponseId, reasonType: reasonType, reasonDetail: reasonDetail)
    }

    func blockUser(userId: Int) async throws {
        try await apiClient.blockUser(userId: userId)
    }

    func loadBlockList(page: Int) async throws -> BlockListResponse {
        try await apiClient.loadBlockList(page: page)
    }

    func unblockUser(userId: Int) async throws {
        try await apiClient.unblockUser(userId: userId)
    }

    func writeReply(responseId: Int, message: String) async throws -> DetailResponseItem {
        return try await apiClient.writeReply(responseId: responseId, message: message)
    }

    func loadReplies(responseId: Int, page: Int) async throws -> ReplyListResponse {
        return try await apiClient.loadReplies(responseId: responseId, page: page)
    }


}
