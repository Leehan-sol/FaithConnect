//
//  PrayerRepositoryProtocol.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/24.
//

import Foundation

protocol PrayerRepositoryProtocol {
    func loadCategories() async throws -> [CategoryResponse]
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerListResponse
    func loadPrayerDetail(prayerRequestID: Int) async throws -> PrayerDetailResponse
    func writePrayer(categoryID: Int, title: String, content: String) async throws -> PrayerWriteResponse
    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> PrayerDetailResponse
    func deletePrayer(prayerRequestId: Int) async throws
    func writePrayerResponse(prayerRequestID: Int, message: String) async throws -> DetailResponseItem
    func updatePrayerResponse(responseID: Int, message: String) async throws -> DetailResponseItem
    func deletePrayerResponse(responseID: Int) async throws
    func loadWrittenPrayers(page: Int) async throws -> PrayerListResponse
    func loadParticipatedPrayers(page: Int) async throws -> MyResponseList
    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func blockUser(userId: Int) async throws
    func loadBlockList(page: Int) async throws -> BlockListResponse
    func unblockUser(userId: Int) async throws
    func writeReply(responseId: Int, message: String) async throws -> DetailResponseItem
    func loadReplies(responseId: Int, page: Int) async throws -> ReplyListResponse
}
