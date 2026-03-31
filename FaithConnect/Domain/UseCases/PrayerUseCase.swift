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
    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> Prayer
    func deletePrayer(prayerRequestId: Int) async throws
    func writePrayerResponse(prayerRequestID: Int, message: String, prayerTitle: String, categoryId: Int, categoryName: String) async throws -> PrayerResponse
    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponse
    func deletePrayerResponse(responseID: Int, prayerRequestId: Int) async throws
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage
    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func blockUser(userId: Int) async throws
}

class PrayerUseCase: PrayerUseCaseProtocol {
    private let repository: PrayerRepositoryProtocol
    var eventPublisher = PassthroughSubject<PrayerEventType, Never>()
    
    init(repository: PrayerRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadCategories() async throws -> [PrayerCategory] {
        let categories = try await repository.loadCategories()
        
        let result = categories.map { PrayerCategory(from: $0) }
        
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
        let result = try await repository.loadPrayers(categoryID: categoryID, 
                                                      page: page)
        
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
        let result = try await repository.writePrayer(categoryID: categoryID, 
                                                      title: title,
                                                      content: content)
        let prayer = Prayer(from: result)
        
        eventPublisher.send(.prayerAdded(prayer: prayer))
        
        return prayer
    }
    
    func updatePrayer(prayerRequestId: Int, categoryID: Int, title: String, content: String) async throws -> Prayer {
        let result = try await repository.updatePrayer(prayerRequestId: prayerRequestId, 
                                                       categoryID: categoryID,
                                                       title: title, 
                                                       content: content)
        let prayer = Prayer(from: result)
        eventPublisher.send(.prayerUpdated(prayer: prayer))
        return prayer
    }

    func deletePrayer(prayerRequestId: Int) async throws {
        try await repository.deletePrayer(prayerRequestId: prayerRequestId)
        eventPublisher.send(.prayerDeleted(prayerId: prayerRequestId))
    }
    
    func writePrayerResponse(prayerRequestID: Int, message: String, prayerTitle: String, categoryId: Int, categoryName: String) async throws -> PrayerResponse {
        let result = try await repository.writePrayerResponse(prayerRequestID: prayerRequestID, 
                                                              message: message)
        let prayerResponse = PrayerResponse(from: result)

        let myResponse = MyResponse(id: prayerResponse.id,
                                    prayerRequestId: prayerRequestID,
                                    prayerRequestTitle: prayerTitle,
                                    categoryId: categoryId,
                                    categoryName: categoryName,
                                    message: message,
                                    createdAt: prayerResponse.createdAt)
        
        eventPublisher.send(.responseAdded(response: myResponse))

        return prayerResponse
    }
    
    func deletePrayerResponse(responseID: Int, prayerRequestId: Int) async throws {
        try await repository.deletePrayerResponse(responseID: responseID)
        eventPublisher.send(.responseDeleted(responseId: responseID, prayerRequestId: prayerRequestId))
    }

    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponse {
        let result = try await repository.updatePrayerResponse(responseID: responseID, 
                                                               message: message)
        let prayerResponse = PrayerResponse(from: result)
        eventPublisher.send(.responseUpdated(response: prayerResponse))
        return prayerResponse
    }
    
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        let result = try await repository.loadWrittenPrayers(page: page)
        
        print("내 기도:", result.prayerRequests.count)
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
    
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage {
        let result = try await repository.loadParticipatedPrayers(page: page)
        
        print("내 응답:", result.responses.count)
        result.responses.forEach { response in
            print("""
                  ─────────────
                  id: \(response.prayerResponseId)
                  title: \(response.message)
                  categoryId: \(response.categoryId)
                  """)
        }
        
        return MyResponsePage(responses: result.responses.map { MyResponse(from: $0) },
                              currentPage: result.currentPage,
                              hasNext: result.hasNext)
    }

    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        try await repository.reportPrayer(prayerRequestId: prayerRequestId, reasonType: reasonType, reasonDetail: reasonDetail)
    }

    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        try await repository.reportPrayerResponse(prayerResponseId: prayerResponseId, reasonType: reasonType, reasonDetail: reasonDetail)
    }

    func blockUser(userId: Int) async throws {
        try await repository.blockUser(userId: userId)
    }

}
