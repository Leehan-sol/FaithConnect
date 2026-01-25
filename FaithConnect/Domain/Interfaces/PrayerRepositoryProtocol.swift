//
//  PrayerRepositoryProtocol.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/24.
//

import Foundation

protocol PrayerRepositoryProtocol {
    func fetchCategories() async throws -> [PrayerCategory]
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage
}
