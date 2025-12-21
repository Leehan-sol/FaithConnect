//
//  Response.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

struct Response: Identifiable, Decodable {
    let id: Int
    let prayerRequestId: String
    let message: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "prayerResponseId"
        case prayerRequestId
        case message
        case createdAt
    }
}
