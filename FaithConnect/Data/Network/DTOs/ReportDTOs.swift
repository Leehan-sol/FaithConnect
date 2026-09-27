//
//  ReportDTOs.swift
//  FaithConnect
//
//  Created by hansol on 2026/03/30.
//

import Foundation

struct ReportPrayerRequest: Encodable {
    let reasonType: ReportReasonType
    let reasonDetail: String?
}

struct ReportResponse: Decodable {
    let message: String
    let success: Bool?
    let errorCode: APIErrorCode?
    let status: Int?
}


struct BlockResponse: Decodable {
    let message: String
    let success: Bool?
    let errorCode: APIErrorCode?
    let status: Int?
}

// MARK: - 차단 목록
struct BlockListResponse: Decodable {
    let blocks: [BlockItem]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
}

struct BlockItem: Decodable {
    let blockId: Int
    let blockedUserId: Int
    let blockedUserName: String
    let createdAt: String
}
