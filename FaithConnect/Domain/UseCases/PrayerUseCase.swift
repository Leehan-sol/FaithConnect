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

    func loadCommunities() async throws -> [CommunityItem]
    func loadCategories() async throws -> [PrayerCategory]
    func loadPrayers(categoryID: Int?, community: Community?, page: Int) async throws -> PrayerPage
    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer
    func writePrayer(categoryID: Int?, community: Community?, visibility: Visibility?, displayNameType: DisplayNameType?, title: String, content: String) async throws -> Prayer
    func updatePrayer(prayerRequestId: Int, categoryID: Int?, community: Community?, visibility: Visibility?, displayNameType: DisplayNameType?, title: String, content: String) async throws -> Prayer
    func deletePrayer(prayerRequestId: Int) async throws
    func writePrayerResponse(prayerRequestID: Int, message: String, visibility: Visibility?, displayNameType: DisplayNameType?, prayerTitle: String, categoryId: Int, categoryName: String) async throws -> PrayerResponse
    func updatePrayerResponse(responseID: Int, message: String) async throws -> PrayerResponse
    func deletePrayerResponse(responseID: Int, prayerRequestId: Int) async throws
    func loadWrittenPrayers(page: Int) async throws -> PrayerPage
    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage
    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws
    func blockUser(userId: Int) async throws
    func loadBlockList(page: Int) async throws -> BlockedUserPage
    func unblockUser(userId: Int) async throws
    func writeReply(responseId: Int, message: String, visibility: Visibility?, displayNameType: DisplayNameType?, prayerRequestId: Int, prayerTitle: String, categoryId: Int, categoryName: String) async throws -> PrayerResponse
    func loadReplies(responseId: Int, page: Int) async throws -> ReplyPage
}

class PrayerUseCase: PrayerUseCaseProtocol {
    private let repository: PrayerRepositoryProtocol
    var eventPublisher = PassthroughSubject<PrayerEventType, Never>()

    init(repository: PrayerRepositoryProtocol) {
        self.repository = repository
    }

    func loadCommunities() async throws -> [CommunityItem] {
        return try await repository.loadCommunities()
    }

    func loadCategories() async throws -> [PrayerCategory] {
        return try await repository.loadCategories()
    }

    func loadPrayers(categoryID: Int?, community: Community?, page: Int) async throws -> PrayerPage {
        return try await repository.loadPrayers(categoryID: categoryID,
                                                community: community,
                                                page: page)
    }

    func loadPrayerDetail(prayerRequestID: Int) async throws -> Prayer {
        return try await repository.loadPrayerDetail(prayerRequestID: prayerRequestID)
    }

    func writePrayer(categoryID: Int?, community: Community?, visibility: Visibility?, displayNameType: DisplayNameType?, title: String, content: String) async throws -> Prayer {
        let prayer = try await repository.writePrayer(categoryID: categoryID,
                                                      community: community,
                                                      visibility: visibility,
                                                      displayNameType: displayNameType,
                                                      title: title,
                                                      content: content)

        eventPublisher.send(.prayerAdded(prayer: prayer))

        return prayer
    }

    func updatePrayer(prayerRequestId: Int, categoryID: Int?, community: Community?, visibility: Visibility?, displayNameType: DisplayNameType?, title: String, content: String) async throws -> Prayer {
        let prayer = try await repository.updatePrayer(prayerRequestId: prayerRequestId,
                                                       categoryID: categoryID,
                                                       community: community,
                                                       visibility: visibility,
                                                       displayNameType: displayNameType,
                                                       title: title,
                                                       content: content)
        eventPublisher.send(.prayerUpdated(prayer: prayer))
        return prayer
    }

    func deletePrayer(prayerRequestId: Int) async throws {
        try await repository.deletePrayer(prayerRequestId: prayerRequestId)
        eventPublisher.send(.prayerDeleted(prayerId: prayerRequestId))
    }

    func writePrayerResponse(prayerRequestID: Int, message: String, visibility: Visibility?, displayNameType: DisplayNameType?, prayerTitle: String, categoryId: Int, categoryName: String) async throws -> PrayerResponse {
        let prayerResponse = try await repository.writePrayerResponse(prayerRequestID: prayerRequestID,
                                                                       message: message,
                                                                       visibility: visibility,
                                                                       displayNameType: displayNameType)

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
        let prayerResponse = try await repository.updatePrayerResponse(responseID: responseID,
                                                                        message: message)
        eventPublisher.send(.responseUpdated(response: prayerResponse))
        return prayerResponse
    }

    func loadWrittenPrayers(page: Int) async throws -> PrayerPage {
        return try await repository.loadWrittenPrayers(page: page)
    }

    func loadParticipatedPrayers(page: Int) async throws -> MyResponsePage {
        return try await repository.loadParticipatedPrayers(page: page)
    }

    func reportPrayer(prayerRequestId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        try await repository.reportPrayer(prayerRequestId: prayerRequestId, reasonType: reasonType, reasonDetail: reasonDetail)
    }

    func reportPrayerResponse(prayerResponseId: Int, reasonType: ReportReasonType, reasonDetail: String?) async throws {
        try await repository.reportPrayerResponse(prayerResponseId: prayerResponseId, reasonType: reasonType, reasonDetail: reasonDetail)
    }

    func blockUser(userId: Int) async throws {
        try await repository.blockUser(userId: userId)
        eventPublisher.send(.userBlocked(userId: userId))
    }

    func loadBlockList(page: Int) async throws -> BlockedUserPage {
        return try await repository.loadBlockList(page: page)
    }

    func unblockUser(userId: Int) async throws {
        try await repository.unblockUser(userId: userId)
    }

    func writeReply(responseId: Int, message: String, visibility: Visibility?, displayNameType: DisplayNameType?, prayerRequestId: Int, prayerTitle: String, categoryId: Int, categoryName: String) async throws -> PrayerResponse {
        let prayerResponse = try await repository.writeReply(responseId: responseId, message: message, visibility: visibility, displayNameType: displayNameType)

        let myResponse = MyResponse(id: prayerResponse.id,
                                    prayerRequestId: prayerRequestId,
                                    prayerRequestTitle: prayerTitle,
                                    categoryId: categoryId,
                                    categoryName: categoryName,
                                    message: message,
                                    createdAt: prayerResponse.createdAt)
        eventPublisher.send(.responseAdded(response: myResponse))

        return prayerResponse
    }

    func loadReplies(responseId: Int, page: Int) async throws -> ReplyPage {
        return try await repository.loadReplies(responseId: responseId, page: page)
    }

}
