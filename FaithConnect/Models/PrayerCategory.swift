//
//  PrayerCategory.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

struct CategoryResponse: Decodable {
    let categoryId: Int
    let categoryCode: Int
    let categoryName: String
}

struct PrayerCategory: Identifiable, Hashable {
    let id: Int // categoryId
    let categoryCode: Int
    let categoryName: String
    
    init(categoryId: Int, categoryCode: Int, categoryName: String) {
        self.id = categoryId
        self.categoryCode = categoryCode
        self.categoryName = categoryName
    }
}
