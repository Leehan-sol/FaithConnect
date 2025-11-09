//
//  Response.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

struct Response: Identifiable {
    let id = UUID()
    let prayerResponseId: Int
    let prayerRequestId: String
    let message: String
    let createdAt: String
    
    init(prayerResponseId: Int, 
         prayerRequestId: String,
         message: String,
         createdAt: String) {
        self.prayerResponseId = prayerResponseId
        self.prayerRequestId = prayerRequestId
        self.message = message
        self.createdAt = createdAt
    }
}
