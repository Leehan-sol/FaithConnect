//
//  MyResponses.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/28.
//

import Foundation

struct MyResponsePage {
    let responses: [MyResponse]
    let currentPage: Int
    let hasNext: Bool
}

struct MyResponse: Identifiable {
    let id: Int // prayerRequestId
    let prayerRequestId: Int
    let prayerRequestTitle: String
    let categoryId: Int
    let categoryName: String
    let message: String
    let createdAt: String
}

// MARK: - Extension
extension MyResponse {
    init(from dto: MyResponseItem){
        self.id = dto.prayerResponseId
        self.prayerRequestId = dto.prayerRequestId
        self.prayerRequestTitle = dto.prayerRequestTitle
        self.categoryId = dto.categoryId
        self.categoryName = dto.categoryName
        self.message = dto.message
        self.createdAt = dto.createdAt
    }
}
