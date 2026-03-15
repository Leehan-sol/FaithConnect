//
//  InquiryDTOs.swift
//  FaithConnect
//
//  Created by hansol on 2026/03/15.
//

import Foundation

struct InquiryRequest: Encodable {
    let title: String
    let content: String
    let userEmail: String
}

struct InquiryResponse: Decodable {
    let message: String
    let success: Bool
    let errorCode: APIErrorCode?
    let status: Int?
}
