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
    @Published var alertType: AlertType? = nil
    
    private let prayerUseCase: PrayerUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage: Int = 1
    private var hasNext: Bool = true
    private var hasInitialized: Bool = false
    
    init(prayerUseCase: PrayerUseCaseProtocol) {
        self.prayerUseCase = prayerUseCase
        bindRepositoryEvents()
    }
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        do {
            categories = try await prayerUseCase.loadCategories()
            guard let firstCategoryId = categories.first?.id else { return }
            selectedCategoryId = firstCategoryId
            try await loadPrayers(categoryID: firstCategoryId,
                                  reset: true)
        } catch {
            alertType = .error(message: error.localizedDescription)
        }
    }

    private func bindRepositoryEvents() {
        prayerUseCase.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handle(event: event)
            }
            .store(in: &cancellables)
    }
    
    private func handle(event: PrayerEventType) {
        switch event {
        case .prayerAdded(let prayer):
            if selectedCategoryId == 1 || selectedCategoryId == prayer.categoryId {
                prayers.insert(prayer, at: 0)
            }
        case .prayerUpdated(let prayer):
            if let index = prayers.firstIndex(where: { $0.id == prayer.id }) {
                prayers[index] = prayer
            }
        case .prayerDeleted(let prayerRequestId):
            prayers.removeAll { $0.id == prayerRequestId }
        case .responseAdded(let response):
            if let index = prayers.firstIndex(where: { $0.id == response.prayerRequestId }) {
                prayers[index].participationCount += 1
            }
        case .responseDeleted(_, let prayerRequestId):
            if let index = prayers.firstIndex(where: { $0.id == prayerRequestId }) {
                prayers[index].participationCount -= 1
            }
        case .responseUpdated:
            break
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
                alertType = .error(message: error.localizedDescription)
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
            alertType = .error(message: error.localizedDescription)
        }
    }
    
    func loadMorePrayers() async {
        do {
            try await loadPrayers(categoryID: selectedCategoryId,
                                  reset: false)
        } catch {
            alertType = .error(message: error.localizedDescription)
        }
    }
    
    func loadPrayers(categoryID: Int, reset: Bool) async throws {
        guard !isLoading && (reset || hasNext) else { return }
        isLoading = true
        defer { isLoading = false }
        
        let pageToLoad = reset ? 1 : currentPage + 1
        
        let prayerPage = try await prayerUseCase.loadPrayers(
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
    
    func makePrayerDetailVM(prayer: Prayer) -> PrayerDetailViewModel {
        return PrayerDetailViewModel(prayerUseCase: prayerUseCase,
                                     prayerRequestId: prayer.id)
    }

    func makePrayerDetailVM(prayerRequestId: Int) -> PrayerDetailViewModel {
        return PrayerDetailViewModel(prayerUseCase: prayerUseCase,
                                     prayerRequestId: prayerRequestId)
    }
    
    func makePrayerEditorVM() -> PrayerEditorViewModel {
        return PrayerEditorViewModel(prayerUseCase: prayerUseCase)
    }

}
