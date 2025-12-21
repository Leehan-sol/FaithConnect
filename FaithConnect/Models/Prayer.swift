//
//  Prayer.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

struct PrayerResponse: Decodable {
    let prayerRequests: [Prayer]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let pageSize: Int
    let hasNext: Bool
    let hasPrevious: Bool
}

struct Prayer: Identifiable, Decodable {
    let id: Int
    let prayerUserId: Int
    let prayerUserName: String
    let categoryId: Int
    let categoryName: String
    let title: String
    let content: String
    let createdAt: String
    let participationCount: Int
    let responses: [Response]?
    let hasParticipated: Bool?
    
    enum CodingKeys: String, CodingKey {
          case id = "prayerRequestId"
          case prayerUserId
          case prayerUserName
          case categoryId
          case categoryName
          case title
          case content
          case createdAt
          case participationCount
          case responses
          case hasParticipated
      }
}

