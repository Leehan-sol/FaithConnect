//
//  PrayerDTOs.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

// MARK: - 기도 목록
struct PrayerListResponse: Decodable {
    let prayerRequests: [PrayerDetailResponse]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let pageSize: Int
    let hasNext: Bool
    let hasPrevious: Bool
}

// MARK: - 기도 상세
struct PrayerDetailResponse: Decodable {
    let prayerRequestId: Int
    let prayerUserId: Int
    let prayerUserName: String
    let categoryId: Int
    let categoryName: String
    let title: String
    let content: String
    let createdAt: String
    let participationCount: Int
    let responses: [PrayerResponse]?
    let hasParticipated: Bool?
}

struct PrayerResponse: Decodable {
    let prayerResponseId: Int
    let prayerRequestId: Int
    let message: String
    let createdAt: String
}

// MARK: - 기도 작성
struct PrayerWriteRequest: Codable {
    let categoryId: Int
    let title: String
    let content: String
}

struct PrayerWriteResponse: Decodable {
    let prayerRequestId: Int
    let prayerUserId: Int
    let prayerUserName: String
    let categoryId: Int
    let categoryName: String
    let title: String
    let content: String
    let createdAt: String
    let participationCount: Int
}

// MARK: - 기도 응답 작성
struct PrayerResponseWriteRequest: Codable {
    let prayerRequestId: Int
    let message: String
}
