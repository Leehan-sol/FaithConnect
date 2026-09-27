//
//  PrayerRepository.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/24.
//

import Foundation
import Combine

class PrayerRepository: PrayerRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadCategories() async throws -> [PrayerCategory] {
        let result = try await apiClient.loadCategories()
        return result.map { PrayerCategory(from: $0) }
    }

    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage {
        let result = try await apiClient.loadPrayers(categoryID: categoryID, page: page)
        return PrayerPage(prayers: result.prayerRequests.map { Prayer(from: $0) },
                          currentPage: result.currentPage,
                          hasNext: result.hasNext)
    }

    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer {
        do {
            let result = try await apiClient.loadPrayerDetail(prayerRequestID: prayerRequestID)
            return Prayer(from: result)
        } catch APIError.serverMessage(let code) where code == .prayerNotFound {
            throw DomainError.prayerNotFound
        }
    }

    func writePrayer(categoryID: Int, title: String, content: String) async throws -> Prayer {
        let result = try await apiClient.writePrayer(categoryID: categoryID, title: title, content: content)
        return Prayer(from: result)
    }

    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> Prayer {
        let result = try await apiClient.updatePrayer(prayerRequestId: prayerRequestId,
                                                       categoryID: categoryID,
                                                       title: title,
                                                       content: content)
        return Prayer(from: result)
    }

    func deletePrayer(prayerRequestId: Int) async throws {
        try await apiClient.deletePrayer(prayerRequestId: prayerRequestId)
    }

    func writePrayerResponse(prayerRequestID: Int, message: String) async throws -> PrayerResponse {
        let result = try await apiClient.writePrayerResponse(prayerRequestID: prayerRequestID,
                                                              message: message)
        return PrayerResponse(from: result)
    }

    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponse {
        let result = try await apiClient.updatePrayerResponse(responseID: responseID,
                                                               message: message)
        return PrayerResponse(from: result)
    }

    func deletePrayerResponse(responseID: Int) async throws {
        return try await apiClient.deletePrayerResponse(responseID: responseID)
    }

    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        let result = try await apiClient.loadWrittenPrayers(page: page)
        return PrayerPage(prayers: result.prayerRequests.map { Prayer(from: $0) },
                          currentPage: result.currentPage,
                          hasNext: result.hasNext)
    }

    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage {
        let result = try await apiClient.loadParticipatedPrayers(page: page)
        return MyResponsePage(responses: result.responses.map { MyResponse(from: $0) },
                              currentPage: result.currentPage,
                              hasNext: result.hasNext)
    }

    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        do {
            try await apiClient.reportPrayer(prayerRequestId: prayerRequestId, reasonType: reasonType, reasonDetail: reasonDetail)
        } catch APIError.serverMessage(let code) where code == .invalidRequestParameter {
            throw DomainError.alreadyReported
        }
    }

    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        do {
            try await apiClient.reportPrayerResponse(prayerResponseId: prayerResponseId, reasonType: reasonType, reasonDetail: reasonDetail)
        } catch APIError.serverMessage(let code) where code == .invalidRequestParameter {
            throw DomainError.alreadyReported
        }
    }

    func blockUser(userId: Int) async throws {
        do {
            try await apiClient.blockUser(userId: userId)
        } catch APIError.serverMessage(let code) where code == .invalidRequestParameter {
            throw DomainError.alreadyBlocked
        }
    }

    func loadBlockList(page: Int) async throws -> BlockedUserPage {
        let result = try await apiClient.loadBlockList(page: page)
        return BlockedUserPage(
            blockedUsers: result.blocks.map { BlockedUser(from: $0) },
            currentPage: result.currentPage,
            hasNext: result.currentPage < result.totalPages
        )
    }

    func unblockUser(userId: Int) async throws {
        try await apiClient.unblockUser(userId: userId)
    }

    func writeReply(responseId: Int, message: String) async throws -> PrayerResponse {
        let result = try await apiClient.writeReply(responseId: responseId, message: message)
        return PrayerResponse(from: result)
    }

    func loadReplies(responseId: Int, page: Int) async throws -> ReplyPage {
        let result = try await apiClient.loadReplies(responseId: responseId, page: page)
        return ReplyPage(replies: result.replies.map { PrayerResponse(from: $0) },
                         currentPage: result.currentPage,
                         hasNext: result.currentPage < result.totalPages)
    }

}
