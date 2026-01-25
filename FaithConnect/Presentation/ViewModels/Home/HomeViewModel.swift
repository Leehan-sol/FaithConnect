//
//  HomeViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var categories: [PrayerCategory] = []
    @Published var prayers: [Prayer] = []
    @Published var isRefreshing: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedCategoryId: Int = 0
    
    private let prayerRepository: PrayerRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage: Int = 1
    private var hasNext: Bool = true
    private var hasInitialized: Bool = false
    
    init(prayerRepository: PrayerRepositoryProtocol) {
        self.prayerRepository = prayerRepository
    }
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        do {
            categories = try await prayerRepository.fetchCategories()
            guard let firstCategoryId = categories.first?.id else { return }
            selectedCategoryId = firstCategoryId
            try await loadPrayers(categoryID: firstCategoryId,
                                  reset: true)
        } catch {
            // TODO: - init 에러시 화면 처리
        }
    }
    
    func selectCategory(categoryID: Int) async {
        guard !isLoading else { return }
        
        if selectedCategoryId == categoryID {
            await refreshPrayers()
        } else {
            selectedCategoryId = categoryID
            
            do {
                try await loadPrayers(categoryID: categoryID, reset: true)
            } catch {
                
            }
            
        }
    }
    
    func refreshPrayers() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            try await loadPrayers(categoryID: selectedCategoryId,
                                  reset: true)
        } catch {
            
        }
    }
    
    func loadMorePrayers() async {
        do {
            try await loadPrayers(categoryID: selectedCategoryId,
                                  reset: false)
        } catch {
            
        }
    }
    
    func loadPrayers(categoryID: Int, reset: Bool) async throws {
        guard !isLoading && (reset || hasNext) else { return }
        isLoading = true
        defer { isLoading = false }
        
        let pageToLoad = reset ? 1 : currentPage + 1
        
        let prayerPage = try await prayerRepository.loadPrayers(
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
        return PrayerDetailViewModel(prayerRepository: prayerRepository,
                                     prayerRequestId: prayer.id)
    }
    
    func makePrayerEditorVM() -> PrayerEditorViewModel {
        return PrayerEditorViewModel(prayerRepository: prayerRepository)
    }
    
    
}
