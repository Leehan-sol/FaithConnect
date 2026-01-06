//
//  Response.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

struct PrayerResponse: Identifiable {
    let id: Int
    let prayerRequestId: Int
    let message: String
    let createdAt: String
    let isMine: Bool
}

// MARK: - Extension
extension PrayerResponse {
    init(from dto: DetailResponseItem) {
        self.id = dto.prayerResponseId
//        self.id = UUID().hashValue // TODO: - 테스트코드
        self.prayerRequestId = dto.prayerRequestId
        self.message = dto.message
        self.createdAt = dto.createdAt
        self.isMine = dto.isMine
    }
}
