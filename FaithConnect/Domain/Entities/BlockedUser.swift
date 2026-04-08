//
//  BlockedUser.swift
//  FaithConnect
//

import Foundation

struct BlockedUserPage {
    let blockedUsers: [BlockedUser]
    let currentPage: Int
    let hasNext: Bool
}

struct BlockedUser: Identifiable {
    let id: Int // blockId
    let userId: Int
    let userName: String
    let createdAt: String
}

extension BlockedUser {
    init(from dto: BlockItem) {
        self.id = dto.blockId
        self.userId = dto.blockedUserId
        self.userName = dto.blockedUserName
        self.createdAt = dto.createdAt
    }
}
