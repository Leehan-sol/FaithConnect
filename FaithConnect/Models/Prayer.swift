//
//  Prayer.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

struct Prayer: Identifiable {
    let id: Int
    let prayerUserName: String
    let categoryId: Int
    let categoryName: String
    let title: String
    let content: String
    let createdAt: String
    let participationCount: Int
    
    init(prayerRequestId: Int, prayerUserName: String, categoryId: Int, categoryName: String, title: String, content: String, createdAt: String, participationCount: Int) {
        self.id = prayerRequestId
        self.prayerUserName = prayerUserName
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.participationCount = participationCount
    }
}
