//
//  PrayerUseCase.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/02.
//

import Foundation
import Combine

protocol PrayerUseCaseProtocol {
    var eventPublisher: PassthroughSubject<PrayerEventType, Never> { get }
    
    func loadCategories() async throws -> [PrayerCategory]
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage
    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer
    func writePrayer(categoryID: Int, title: String, content: String) async throws -> Prayer
    func deletePrayer(prayerRequestId: Int) async throws
    func writePrayerResponse(prayerRequsetID: Int, message: String) async throws -> PrayerResponse
    func deletePrayerResponse(responseID: Int) async throws
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage
}

class PrayerUseCase: PrayerUseCaseProtocol {
    private let repository: PrayerRepositoryProtocol
    var eventPublisher = PassthroughSubject<PrayerEventType, Never>()
    
    init(repository: PrayerRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadCategories() async throws -> [PrayerCategory] {
        let categories = try await repository.loadCategories()
        
        let result = categories.map { response in
            PrayerCategory(id: response.categoryId,
                           categoryCode: response.categoryCode,
                           categoryName: response.categoryName)
        }
        
        print("카테고리:", result.count)
        result.forEach { category in
            print("""
                      ─────────────
                      id: \(category.id)
                      name: \(category.categoryName)
                      """)
        }
        
        return result
    }
    
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage {
        let result = try await repository.loadPrayers(categoryID: categoryID, page: page)
        
        result.prayerRequests.forEach { prayer in
            print("""
                  ─────────────
                  id: \(prayer.prayerRequestId)
                  title: \(prayer.title)
                  categoryId: \(prayer.categoryId)
                  """)
        }
        
        return PrayerPage(prayers: result.prayerRequests.map { Prayer(from: $0) },
                          currentPage: result.currentPage,
                          hasNext: result.hasNext)
    }
    
    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer {
        let result = try await repository.loadPrayerDetail(prayerRequestID: prayerRequestID)
        
        return Prayer(from: result)
    }
    
    func writePrayer(categoryID: Int, title: String, content: String) async throws -> Prayer {
        let result = try await repository.writePrayer(categoryID: categoryID, title: title, content: content)
        let prayer = Prayer(from: result)
        eventPublisher.send(.prayerAdded(prayer: prayer))
        
        return prayer
    }
    
    func deletePrayer(prayerRequestId: Int) async throws {
        try await repository.deletePrayer(prayerRequestId: prayerRequestId)
        eventPublisher.send(.prayerDeleted(prayerId: prayerRequestId))
    }
    
    func writePrayerResponse(prayerRequsetID: Int, message: String) async throws -> PrayerResponse {
        let result = try await repository.writePrayerResponse(prayerRequsetID: prayerRequsetID, message: message)
        
        return PrayerResponse(from: result)
    }
    
    func deletePrayerResponse(responseID: Int) async throws {
        return try await repository.deletePrayerResponse(responseID: responseID)
    }
    
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        let result = try await repository.loadWrittenPrayers(page: page)
        
        return PrayerPage(prayers: result.prayerRequests.map { Prayer(from: $0) },
                          currentPage: result.currentPage,
                          hasNext: result.hasNext)
    }
    
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage {
        let result = try await repository.loadParticipatedPrayers(page: page)
        
        return MyResponsePage(responses: result.responses.map { MyResponse(from: $0) },
                              currentPage: result.currentPage,
                              hasNext: result.hasNext)
    }
    
}
