//
//  DomainError.swift
//  FaithConnect
//

import Foundation

enum DomainError: LocalizedError {
    case prayerNotFound
    case alreadyReported
    case alreadyBlocked
    case networkError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .prayerNotFound:
            return "해당 기도를 찾을 수 없습니다."
        case .alreadyReported:
            return "이미 신고한 게시물입니다."
        case .alreadyBlocked:
            return "이미 차단한 사용자입니다."
        case .networkError(let message):
            return message
        case .unknown(let message):
            return message
        }
    }
}
