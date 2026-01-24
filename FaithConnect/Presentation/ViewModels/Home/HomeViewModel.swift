//
//  HomeViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var categories: [PrayerCategory] = []
    @Published var prayers: [Prayer] = []
    @Published var isRefreshing: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedCategoryId: Int = 0
    
    private let apiClient: APIClientProtocol
    private var currentPage: Int = 1
    private var hasNext: Bool = true
    private var hasInitialized: Bool = false

    init(_ apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func initializeIfNeeded(categoryID: Int) async {
        guard !hasInitialized else { return }
        hasInitialized = true
        selectedCategoryId = categoryID
        await loadPrayers(categoryID: categoryID,
                          reset: true)
    }
    
    func selectCategory(categoryID: Int) async {
        guard !isLoading else { return }
        
        if selectedCategoryId == categoryID {
            await refreshPrayers()
        } else {
            selectedCategoryId = categoryID
            await loadPrayers(categoryID: categoryID, reset: true)
        }
    }
    
    func refreshPrayers() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        await loadPrayers(categoryID: selectedCategoryId,
                          reset: true)
        isRefreshing = false
    }
    
    func loadMorePrayers() async {
        await loadPrayers(categoryID: selectedCategoryId, 
                          reset: false)
    }
    
    func loadPrayers(categoryID: Int, reset: Bool) async {
        guard !isLoading && (reset || hasNext) else { return }
        isLoading = true
        defer { isLoading = false }
        
        let pageToLoad = reset ? 1 : currentPage + 1
        
        do {
            let prayerPage = try await apiClient.loadPrayers(
                categoryID: categoryID,
                page: pageToLoad
            )
            
            guard categoryID == self.selectedCategoryId else { return }
            
            if reset {
                prayers = prayerPage.prayers
                currentPage = 1
            } else {
                prayers.append(contentsOf: prayerPage.prayers)
                currentPage = pageToLoad
            }
            
            hasNext = prayerPage.hasNext
        } catch {
            print(error)
        }
    }
    
    func addPrayer(prayer: Prayer) {
        if selectedCategoryId == prayer.categoryId {
            prayers.insert(prayer, at: 0)
        }
    }
    
    func deletePrayer(id: Int) {
        prayers.removeAll { $0.id == id }
    }
    
    func makePrayerDetailVM(prayer: Prayer) -> PrayerDetailViewModel {
        return PrayerDetailViewModel(apiClient,
                                     prayerRequestId: prayer.id)
    }
    
    func makePrayerEditorVM() -> PrayerEditorViewModel {
        return PrayerEditorViewModel(apiClient)
    }
    
    
}
