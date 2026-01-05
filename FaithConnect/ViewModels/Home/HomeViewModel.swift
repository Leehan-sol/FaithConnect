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
    private var hasInitialized = false
    private var currentPage: Int = 0
    private var hasNext: Bool = true
    
    init(_ apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func initializeIfNeeded(categories: [PrayerCategory]) async {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        guard let first = categories.first else { return }
        selectedCategoryId = first.id
        
        await loadPrayers(reset: true)
    }
    
    func selectCategory(id: Int) async {
        guard selectedCategoryId != id else { return }
        selectedCategoryId = id
        prayers.removeAll()
        
        await loadPrayers(reset: true)
    }
    
    func refreshPrayers() async {
        guard !isLoading else { return }
        isRefreshing = true
        
        await loadPrayers(reset: true)
        isRefreshing = false
    }
    
    func loadPrayers(reset: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let prayerPage = try await apiClient.loadPrayers(
                categoryId: selectedCategoryId,
                page: reset ? 0 : currentPage
            )
            
            if reset {
                prayers = prayerPage.prayers
                currentPage = 0
                hasNext = true
            } else {
                prayers.append(contentsOf: prayerPage.prayers)
                currentPage += 1
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
