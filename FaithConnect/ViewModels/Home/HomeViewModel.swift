//
//  HomeViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    let apiService: APIServiceProtocol
    @Published var categories: [PrayerCategory] = []
    @Published var prayers: [Prayer] = []
    @Published var currentPage: Int = 1
    @Published var hasNext: Bool = true
    @Published var isLoading: Bool = false
    
    init(_ apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func loadCategories() async {
        do {
            let loadCategory = try await apiService.loadCategories()
            categories = loadCategory
            print(categories)
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    func loadPrayers(categoryId: Int, reset: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        
        if reset {
            currentPage = 1
            hasNext = true
            prayers.removeAll()
        }
        
        do {
            let response = try await apiService.loadPrayers(categoryId: categoryId,
                                                            page: currentPage)
            prayers.append(contentsOf: response.prayerRequests)
            currentPage += 1
            hasNext = response.hasNext
        } catch {
            print("Error loading prayers: \(error)")
        }
        
        isLoading = false
    }
    
//    func loadMoreIfNeeded(currentItem: Prayer, selectedCategory: Int) async {
//        guard hasNext,
//              !isLoading,
//              currentItem.id == prayers.last?.id else {
//            return
//        }
//        
//        await loadPrayers(selectedCategory: selectedCategory, reset: false)
//    }
    
}
