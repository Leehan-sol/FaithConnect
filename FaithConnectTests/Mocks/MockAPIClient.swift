//
//  MockAPIClient.swift
//  FaithConnectTests
//

import Foundation
@testable import FaithConnect

class MockAPIClient: APIClientProtocol {

    // MARK: - 스텁 설정
    var stubbedHasToken: Bool = false
    var stubbedCategories: [CategoryResponse] = []
    var stubbedPrayerList: PrayerListResponse?
    var stubbedPrayerDetail: PrayerDetailResponse?
    var stubbedPrayerWrite: PrayerWriteResponse?
    var stubbedResponseItem: DetailResponseItem?
    var stubbedMyResponseList: MyResponseList?
    var stubbedBlockList: BlockListResponse?
    var stubbedReplyList: ReplyListResponse?
    var stubbedMyInfo: FetchMyInfoResponse?
    var stubbedFoundEmail: String = ""
    var stubbedNickname: String = ""
    var stubbedError: Error?

    // MARK: - APIClientProtocol
    var hasToken: Bool { stubbedHasToken }

    // MARK: - Auth
    func signUp(name: String, nickname: String, email: String, password: String, confirmPassword: String) async throws {
        if let error = stubbedError { throw error }
    }

    func requestEmailVerification(email: String) async throws {
        if let error = stubbedError { throw error }
    }

    func confirmEmailVerification(email: String, verificationCode: String) async throws {
        if let error = stubbedError { throw error }
    }

    func login(email: String, password: String) async throws {
        if let error = stubbedError { throw error }
    }

    func logout() async throws {
        if let error = stubbedError { throw error }
    }

    func fetchMyInfo() async throws -> FetchMyInfoResponse {
        if let error = stubbedError { throw error }
        return stubbedMyInfo!
    }

    func findID(name: String, nickname: String) async throws -> String {
        if let error = stubbedError { throw error }
        return stubbedFoundEmail
    }

    func changePassword(id: Int, name: String, email: String, newPassword: String) async throws {
        if let error = stubbedError { throw error }
    }

    func changeNickname(nickname: String) async throws -> String {
        if let error = stubbedError { throw error }
        return stubbedNickname
    }

    func deleteAccount() async throws {
        if let error = stubbedError { throw error }
    }

    func requestPasswordReset(email: String) async throws {
        if let error = stubbedError { throw error }
    }

    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        if let error = stubbedError { throw error }
    }

    // MARK: - Push Token
    func registerPushToken(deviceToken: String) async throws {
        if let error = stubbedError { throw error }
    }

    func deletePushToken(deviceToken: String) async throws {
        if let error = stubbedError { throw error }
    }

    func testPush(title: String, body: String, data: [String: String]?) async throws {
        if let error = stubbedError { throw error }
    }

    // MARK: - Inquiry
    func sendInquiry(title: String, content: String, userEmail: String) async throws {
        if let error = stubbedError { throw error }
    }

    // MARK: - Prayer
    func loadCategories() async throws -> [CategoryResponse] {
        if let error = stubbedError { throw error }
        return stubbedCategories
    }

    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerListResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerList!
    }

    func loadPrayerDetail(prayerRequestID: Int) async throws -> PrayerDetailResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerDetail!
    }

    func writePrayer(categoryID: Int, title: String, content: String) async throws -> PrayerWriteResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerWrite!
    }

    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> PrayerDetailResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerDetail!
    }

    func deletePrayer(prayerRequestId: Int) async throws {
        if let error = stubbedError { throw error }
    }

    func writePrayerResponse(prayerRequestID: Int, message: String) async throws -> DetailResponseItem {
        if let error = stubbedError { throw error }
        return stubbedResponseItem!
    }

    func updatePrayerResponse(responseID: Int, message: String) async throws -> DetailResponseItem {
        if let error = stubbedError { throw error }
        return stubbedResponseItem!
    }

    func deletePrayerResponse(responseID: Int) async throws {
        if let error = stubbedError { throw error }
    }

    func loadWrittenPrayers(page: Int) async throws -> PrayerListResponse {
        if let error = stubbedError { throw error }
        return stubbedPrayerList!
    }

    func loadParticipatedPrayers(page: Int) async throws -> MyResponseList {
        if let error = stubbedError { throw error }
        return stubbedMyResponseList!
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

    func loadBlockList(page: Int) async throws -> BlockListResponse {
        if let error = stubbedError { throw error }
        return stubbedBlockList!
    }

    func unblockUser(userId: Int) async throws {
        if let error = stubbedError { throw error }
    }

    func writeReply(responseId: Int, message: String) async throws -> DetailResponseItem {
        if let error = stubbedError { throw error }
        return stubbedResponseItem!
    }

    func loadReplies(responseId: Int, page: Int) async throws -> ReplyListResponse {
        if let error = stubbedError { throw error }
        return stubbedReplyList!
    }
}
