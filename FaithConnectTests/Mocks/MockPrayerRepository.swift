//
//  MockPrayerRepository.swift
//  FaithConnectTests
//

import Foundation
@testable import FaithConnect

class MockPrayerRepository: PrayerRepositoryProtocol {

    // MARK: - 스텁 설정
    var stubbedCategories: [CategoryResponse] = []
    var stubbedPrayerList: PrayerListResponse?
    var stubbedPrayerDetail: PrayerDetailResponse?
    var stubbedPrayerWrite: PrayerWriteResponse?
    var stubbedResponseItem: DetailResponseItem?
    var stubbedResponseUpdate: PrayerResponseUpdateResponse?
    var stubbedMyResponseList: MyResponseList?
    var stubbedError: Error?

    // MARK: - 호출 추적
    var loadCategoriesCalled = false
    var deletePrayerCalledWith: Int?
    var deletePrayerResponseCalledWith: Int?

    // MARK: - PrayerRepositoryProtocol
    func loadCategories() async throws -> [CategoryResponse] {
        loadCategoriesCalled = true
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
        deletePrayerCalledWith = prayerRequestId
        if let error = stubbedError { throw error }
    }

    func writePrayerResponse(prayerRequestID: Int, message: String) async throws -> DetailResponseItem {
        if let error = stubbedError { throw error }
        return stubbedResponseItem!
    }

    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponseUpdateResponse {
        if let error = stubbedError { throw error }
        return stubbedResponseUpdate!
    }

    func deletePrayerResponse(responseID: Int) async throws {
        deletePrayerResponseCalledWith = responseID
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
}
