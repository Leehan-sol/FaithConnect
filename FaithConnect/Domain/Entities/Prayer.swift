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
    let categoryId: Int
    let categoryName: String
    let title: String
    let content: String
    let createdAt: String
    var participationCount: Int
    var responses: [PrayerResponse]?
    let isMine: Bool
}


// MARK: - Extension
extension Prayer {
    init(from dto: PrayerDetailResponse) {
        self.id = dto.prayerRequestId
        self.userId = dto.prayerUserId
        self.userName = dto.prayerUserName
        self.categoryId = dto.categoryId
        self.categoryName = dto.categoryName
        self.title = dto.title
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.participationCount = dto.participationCount
        self.responses = dto.responses?.map { PrayerResponse(from: $0) }
        self.isMine = dto.isMine
    }
    
    init(from dto: PrayerWriteResponse) {
        self.id = dto.prayerRequestId
//        self.id = UUID().hashValue // TODO: - 테스트코드
        self.userId = dto.prayerUserId
        self.userName = dto.prayerUserName
        self.categoryId = dto.categoryId
        self.categoryName = dto.categoryName
        self.title = dto.title
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.participationCount = dto.participationCount
        self.responses = []
        self.isMine = dto.isMine
    }
}
