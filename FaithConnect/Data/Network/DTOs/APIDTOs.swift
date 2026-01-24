//
//  APIDTOs.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/05.
//

import Foundation

struct EmptyRequest: Codable {
    
}

struct EmptyResponse: Decodable {
    
}

struct APIErrorResponse: Decodable {
    let errorCode: APIErrorCode
    let message: String
}

