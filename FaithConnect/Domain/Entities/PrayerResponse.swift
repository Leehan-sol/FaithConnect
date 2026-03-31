//
//  Response.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

struct PrayerResponse: Identifiable, Equatable {
    let id: Int
    let prayerRequestId: Int
    let userId: Int
    let userName: String
    let message: String
    let createdAt: String
    let isMine: Bool
    let parentResponseId: Int?
    let replyCount: Int
    var replies: [PrayerResponse] = []
}

// MARK: - Extension
extension PrayerResponse {
    init(from dto: DetailResponseItem) {
        self.id = dto.prayerResponseId
//        self.id = UUID().hashValue // 테스트코드
        self.prayerRequestId = dto.prayerRequestId
        self.userId = dto.prayerUserId ?? 0
        self.userName = dto.prayerUserName ?? ""
        self.message = dto.message
        self.createdAt = dto.createdAt
        self.isMine = dto.isMine
        self.parentResponseId = dto.parentResponseId
        self.replyCount = dto.replyCount ?? 0
    }

    init(from dto: PrayerResponseUpdateResponse) {
        self.id = dto.prayerResponseId
        self.prayerRequestId = dto.prayerRequestId
        self.userId = 0
        self.userName = ""
        self.message = dto.message
        self.createdAt = dto.createdAt
        self.isMine = dto.isMine
        self.parentResponseId = nil
        self.replyCount = 0
    }
}
