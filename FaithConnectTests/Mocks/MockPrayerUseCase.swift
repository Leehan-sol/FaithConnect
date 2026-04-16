//
//  MockPrayerUseCase.swift
//  FaithConnectTests
//

import Foundation
import Combine
@testable import FaithConnect

class MockPrayerUseCase: PrayerUseCaseProtocol {

    // MARK: - 스텁 설정
    var eventPublisher = PassthroughSubject<PrayerEventType, Never>()
    var stubbedCategories: [PrayerCategory] = []
    var stubbedPrayerPage: PrayerPage = PrayerPage(prayers: [], currentPage: 1, hasNext: false)
    var stubbedPrayer: Prayer?
    var stubbedPrayerResponse: PrayerResponse?
    var stubbedMyResponsePage: MyResponsePage = MyResponsePage(responses: [], currentPage: 1, hasNext: false)
    var stubbedBlockedUserPage: BlockedUserPage = BlockedUserPage(blockedUsers: [], currentPage: 1, hasNext: false)
    var stubbedReplyPage: ReplyPage = ReplyPage(replies: [], currentPage: 1, hasNext: false)
    var stubbedError: Error?

    // MARK: - 호출 추적
    var loadCategoriesCalled = false
    var loadPrayersCalledWith: (categoryID: Int, page: Int)?
    var loadPrayerDetailCalledWith: Int?
    var writePrayerCalledWith: (categoryID: Int, title: String, content: String)?
    var deletePrayerCalledWith: Int?
    var writePrayerResponseCalledWith: (prayerRequestID: Int, message: String)?
    var loadWrittenPrayersCalledWith: Int?
    var loadParticipatedPrayersCalledWith: Int?

    // MARK: - PrayerUseCaseProtocol
    func loadCategories() async throws -> [PrayerCategory] {
        loadCategoriesCalled = true
        if let error = stubbedError { throw error }
        return stubbedCategories
    }

    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage {
        loadPrayersCalledWith = (categoryID, page)
        if let error = stubbedError { throw error }
        return stubbedPrayerPage
    }

    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer {
        loadPrayerDetailCalledWith = prayerRequestID
        if let error = stubbedError { throw error }
        return stubbedPrayer!
    }

    func writePrayer(categoryID: Int, title: String, content: String) async throws -> Prayer {
        writePrayerCalledWith = (categoryID, title, content)
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

    func writePrayerResponse(prayerRequestID: Int, message: String, prayerTitle: String, categoryId: Int, categoryName: String) async throws -> PrayerResponse {
        writePrayerResponseCalledWith = (prayerRequestID, message)
        if let error = stubbedError { throw error }
        return stubbedPrayerResponse!
    }

    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerResponse!
    }

    func deletePrayerResponse(responseID: Int, prayerRequestId: Int) async throws {
        if let error = stubbedError { throw error }
    }

    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        loadWrittenPrayersCalledWith = page
        if let error = stubbedError { throw error }
        return stubbedPrayerPage
    }

    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage {
        loadParticipatedPrayersCalledWith = page
        if let error = stubbedError { throw error }
        return stubbedMyResponsePage
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
        return stubbedBlockedUserPage
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
        return stubbedReplyPage
    }
}
