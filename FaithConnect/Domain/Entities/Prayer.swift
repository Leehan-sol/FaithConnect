//
//  Prayer.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

struct PrayerPage {
    let prayers: [Prayer]
    let currentPage: Int
    let hasNext: Bool
}

struct Prayer: Identifiable {
    let id: Int // prayerRequestId
    let userId: Int
    let userName: String
    let categoryId: Int?
    let categoryName: String?
    let community: String?
    let visibility: Visibility?
    let displayNameType: DisplayNameType?
    let title: String
    let content: String
    let createdAt: String
    var participationCount: Int
    var responses: [PrayerResponse]?
    let hasParticipated: Bool
    let isMine: Bool
}


// MARK: - Computed
extension Prayer {
    var displayLabel: String {
        if let community = community,
           let c = Community(rawValue: community) {
            return c.displayName
        }
        return categoryName ?? ""
    }
}

// MARK: - Extension
extension Prayer {
    init(from dto: PrayerDetailResponse) {
        self.id = dto.prayerRequestId
        self.userId = dto.prayerUserId ?? 0
        self.userName = dto.prayerUserName ?? ""
        self.categoryId = dto.categoryId ?? 0
        self.categoryName = dto.categoryName ?? ""
        self.community = dto.community
        self.visibility = dto.visibility.flatMap { Visibility(rawValue: $0) }
        self.displayNameType = dto.displayNameType.flatMap { DisplayNameType(rawValue: $0) }
        self.title = dto.title ?? ""
        self.content = dto.content ?? ""
        self.createdAt = dto.createdAt ?? ""
        self.participationCount = dto.participationCount
        self.responses = dto.responses?.map { PrayerResponse(from: $0) }
        self.hasParticipated = dto.hasParticipated ?? false
        self.isMine = dto.isMine
    }

    init(from dto: PrayerWriteResponse) {
        self.id = dto.prayerRequestId
        self.userId = dto.prayerUserId
        self.userName = dto.prayerUserName
        self.categoryId = dto.categoryId ?? 0
        self.categoryName = dto.categoryName ?? ""
        self.community = dto.community
        self.visibility = dto.visibility.flatMap { Visibility(rawValue: $0) }
        self.displayNameType = dto.displayNameType.flatMap { DisplayNameType(rawValue: $0) }
        self.title = dto.title
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.participationCount = dto.participationCount
        self.responses = []
        self.hasParticipated = false
        self.isMine = dto.isMine
    }
}
