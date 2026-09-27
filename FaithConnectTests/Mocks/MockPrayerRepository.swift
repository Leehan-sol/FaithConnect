//
//  MockPrayerRepository.swift
//  FaithConnectTests
//

import Foundation
@testable import FaithConnect

class MockPrayerRepository: PrayerRepositoryProtocol {

    // MARK: - 스텁 설정
    var stubbedCategories: [PrayerCategory] = []
    var stubbedPrayerPage: PrayerPage?
    var stubbedPrayer: Prayer?
    var stubbedPrayerResponse: PrayerResponse?
    var stubbedMyResponsePage: MyResponsePage?
    var stubbedBlockedUserPage: BlockedUserPage?
    var stubbedReplyPage: ReplyPage?
    var stubbedError: Error?

    // MARK: - 호출 추적
    var loadCategoriesCalled = false
    var deletePrayerCalledWith: Int?
    var deletePrayerResponseCalledWith: Int?

    // MARK: - PrayerRepositoryProtocol
    func loadCategories() async throws -> [PrayerCategory] {
        loadCategoriesCalled = true
        if let error = stubbedError { throw error }
        return stubbedCategories
    }

    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage {
        if let error = stubbedError { throw error }
        return stubbedPrayerPage!
    }

    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer {
        if let error = stubbedError { throw error }
        return stubbedPrayer!
    }

    func writePrayer(categoryID: Int, title: String, content: String) async throws -> Prayer {
        if let error = stubbedError { throw error }
        return stubbedPrayer!
    }

    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> Prayer {
        if let error = stubbedError { throw error }
        return stubbedPrayer!
    }

    func deletePrayer(prayerRequestId: Int) async throws {
        deletePrayerCalledWith = prayerRequestId
        if let error = stubbedError { throw error }
    }

    func writePrayerResponse(prayerRequestID: Int, message: String) async throws -> PrayerResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerResponse!
    }

    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerResponse!
    }

    func deletePrayerResponse(responseID: Int) async throws {
        deletePrayerResponseCalledWith = responseID
        if let error = stubbedError { throw error }
    }

    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        if let error = stubbedError { throw error }
        return stubbedPrayerPage!
    }

    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage {
        if let error = stubbedError { throw error }
        return stubbedMyResponsePage!
    }

    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        if let error = stubbedError { throw error }
    }

    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        if let error = stubbedError { throw error }
    }

    func blockUser(userId: Int) async throws {
        if let error = stubbedError { throw error }
    }

    func loadBlockList(page: Int) async throws -> BlockedUserPage {
        if let error = stubbedError { throw error }
        return stubbedBlockedUserPage!
    }

    func unblockUser(userId: Int) async throws {
        if let error = stubbedError { throw error }
    }

    func writeReply(responseId: Int, message: String) async throws -> PrayerResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerResponse!
    }

    func loadReplies(responseId: Int, page: Int) async throws -> ReplyPage {
        if let error = stubbedError { throw error }
        return stubbedReplyPage!
    }
}
