//
//  PrayerRepository.swift
//  FaithConnect
//
//  Created by hansol on 2026/01/24.
//

import Foundation
import Combine

class PrayerRepository: ObservableObject, PrayerRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchCategories() async throws -> [PrayerCategory] {
        return try await apiClient.loadCategories()
    }
    
    func loadPrayers(categoryID: Int, page: Int) async throws -> PrayerPage {
        return try await apiClient.loadPrayers(categoryID: categoryID, page: page)
    }
    
}
