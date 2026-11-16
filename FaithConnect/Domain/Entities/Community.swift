//
//  Community.swift
//  FaithConnect
//

import Foundation

struct CommunityItem: Identifiable, Equatable {
    let community: String
    let displayName: String

    var id: String { community }
}
