//
//  PrayerRepositoryProtocol.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/24.
//

import Foundation

protocol PrayerRepositoryProtocol {
    func loadCategories() async throws -> [PrayerCategory]
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage
    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer
    func writePrayer(categoryID: Int, title: String, content: String) async throws -> Prayer
    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> Prayer
    func deletePrayer(prayerRequestId: Int) async throws
    func writePrayerResponse(prayerRequestID: Int, message: String) async throws -> PrayerResponse
    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponse
    func deletePrayerResponse(responseID: Int) async throws
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage
    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func blockUser(userId: Int) async throws
    func loadBlockList(page: Int) async throws -> BlockedUserPage
    func unblockUser(userId: Int) async throws
    func writeReply(responseId: Int, message: String) async throws -> PrayerResponse
    func loadReplies(responseId: Int, page: Int) async throws -> ReplyPage
}
