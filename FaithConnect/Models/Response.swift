//
//  Response.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

struct Response: Identifiable {
    let id: Int
    let prayerRequestId: Int
    let message: String
    let createdAt: String
}

// MARK: - Extension
extension Response {
    init(from dto: PrayerResponse) {
        self.id = dto.prayerResponseId
        self.prayerRequestId = dto.prayerRequestId
        self.message = dto.message
        self.createdAt = dto.createdAt
    }
}
