//
//  Response.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

struct ReplyPage {
    let replies: [PrayerResponse]
    let currentPage: Int
    let hasNext: Bool
}

struct PrayerResponse: Identifiable, Equatable {
    let id: Int
    let prayerRequestId: Int
    let userId: Int
    let userName: String
    var message: String
    let visibility: Visibility?
    let displayNameType: DisplayNameType?
    let role: UserRole?
    let createdAt: String
    let isMine: Bool
    let parentResponseId: Int?
    var replyCount: Int
    var replies: [PrayerResponse] = []
}

// MARK: - Extension
extension PrayerResponse {
    init(from dto: DetailResponseItem) {
        self.id = dto.prayerResponseId
        self.prayerRequestId = dto.prayerRequestId
        self.userId = dto.prayerUserId ?? 0
        self.userName = dto.prayerUserName ?? ""
        self.message = dto.message
        self.visibility = dto.visibility.flatMap { Visibility(rawValue: $0) }
        self.displayNameType = dto.displayNameType.flatMap { DisplayNameType(rawValue: $0) }
        self.role = dto.role.flatMap { UserRole(rawValue: $0) }
        self.createdAt = dto.createdAt
        self.isMine = dto.isMine
        self.parentResponseId = dto.parentResponseId
        self.replyCount = dto.replyCount ?? 0
    }
}
