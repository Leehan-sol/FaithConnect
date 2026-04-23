//
//  ContentStatus.swift
//  FaithConnect
//

import Foundation

enum ContentStatus: String, Decodable {
    case normal = "NORMAL"
    case deleted = "DELETED"
    case blocked = "BLOCKED"
}
