//
//  PrayerRepositoryProtocol.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/24.
//

import Foundation
import Combine

protocol PrayerRepositoryProtocol {
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
