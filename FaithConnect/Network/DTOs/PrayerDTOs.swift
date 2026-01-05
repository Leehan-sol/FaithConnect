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
    let responses: [DetailResponseItem]?
    let hasParticipated: Bool?
}

struct DetailResponseItem: Decodable {
    let prayerResponseId: Int
    let prayerRequestId: Int
    let prayerRequestTitle: String?
    let message: String
    let createdAt: String
}

// MARK: - 기도 삭제
struct PrayerDeleteResponse: Decodable {
    let message: String
    let success: Bool?
    let errorCode: Int?
    let status: Int?
}

// MARK: - 내 응답 목록
struct MyResponseList: Decodable {
    let responses: [MyResponseItem]
    let currentPage: Int
    let totalElements: Int
    let pageSize: Int
    let hasNext: Bool
    let hasPrevious: Bool
}

struct MyResponseItem: Decodable {
    let prayerRequestId: Int
    let prayerResponseId: Int
    let prayerRequestTitle: String
    let categoryId: Int
    let categoryName: String
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
