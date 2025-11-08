//
//  Prayer.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

struct Prayer: Identifiable {
    let id: Int // prayerRequestId
    let prayerUserId: String
    let prayerUserName: String
    let categoryId: Int
    let categoryName: String
    let title: String
    let content: String
    let createdAt: String
    let participationCount: Int
    let responses: [Response]
//    let myResponse: String
    let hasParticipated: Bool
    
    init(prayerRequestId: Int,
         prayerUserId: String,
         prayerUserName: String,
         categoryId: Int,
         categoryName: String,
         title: String,
         content: String,
         createdAt: String,
         participationCount: Int,
         responses: [Response],
//         myResponse: String,
         hasParticipated: Bool) {
        self.id = prayerRequestId
        self.prayerUserId = prayerUserId
        self.prayerUserName = prayerUserName
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.participationCount = participationCount
        self.responses = responses
//        self.myResponse = myResponse
        self.hasParticipated = hasParticipated
    }
}

