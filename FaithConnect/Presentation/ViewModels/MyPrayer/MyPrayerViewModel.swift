//
//  MyPrayerViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation
import Combine

@MainActor
class MyPrayerViewModel: ObservableObject {
    @Published var writtenPrayers: [Prayer] = []
    @Published var participatedPrayers: [MyResponse] = []
    @Published var isLoadingWrittenPrayers: Bool = false
    @Published var isRefreshingWrittenPrayers: Bool = false
    @Published var isLoadingParticipatedPrayers: Bool = false
    @Published var isRefreshingParticipatedPrayers: Bool = false
    @Published var alertType: AlertType? = nil
    
    private let prayerUseCase: PrayerUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var hasInitialized = false
    private var currentWrittenPage: Int = 1
    private var currentParticipatedPage: Int = 1
    private var hasNextWrittenPage: Bool = false
    private var hasNextParticipatedPage: Bool = false
    
    init(prayerUseCase: PrayerUseCaseProtocol) {
        self.prayerUseCase = prayerUseCase
        bindRepositoryEvents()
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
            writtenPrayers.insert(prayer, at: 0)
        case .prayerUpdated(let prayer):
            if let index = writtenPrayers.firstIndex(where: { $0.id == prayer.id }) {
                writtenPrayers[index] = prayer
            }
        case .prayerDeleted(let prayerId):
            writtenPrayers.removeAll { $0.id == prayerId }
        case .responseAdded(let response):
            participatedPrayers.insert(response, at: 0)
            if let index = writtenPrayers.firstIndex(where: { $0.id == response.prayerRequestId }) {
                writtenPrayers[index].participationCount += 1
            }
        case .responseUpdated(let response):
            if let index = participatedPrayers.firstIndex(where: { $0.id == response.id }) {
                participatedPrayers[index].message = response.message
            }
        case .responseDeleted(let responseId, let prayerRequestId):
            participatedPrayers.removeAll { $0.id == responseId }
            if let index = writtenPrayers.firstIndex(where: { $0.id == prayerRequestId }) {
                writtenPrayers[index].participationCount -= 1
            }
        case .userBlocked(let userId):
            writtenPrayers.removeAll { $0.userId == userId }
        }
    }
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        await loadWrittenPrayers(reset: true)
        await loadParticipatedPrayers(reset: true)
    }
    
    // MARK: - 내가 올린 기도
    func refreshWrittenPrayers() async {
        guard !isLoadingWrittenPrayers else { return }
        isRefreshingWrittenPrayers = true
        
        await loadWrittenPrayers(reset: true)
        isRefreshingWrittenPrayers = false
    }
    
    func loadWrittenPrayers(reset: Bool) async {
        guard !isLoadingWrittenPrayers && (reset || hasNextWrittenPage) else { return }
        isLoadingWrittenPrayers = true
        defer { isLoadingWrittenPrayers = false }

        let pageToLoad = reset ? 1 : currentWrittenPage + 1

        do {
            let prayerPage = try await prayerUseCase.loadWrittenPrayers(page: pageToLoad)

            if reset {
                writtenPrayers = prayerPage.prayers
            } else {
                writtenPrayers.append(contentsOf: prayerPage.prayers)
            }
            currentWrittenPage = pageToLoad
            hasNextWrittenPage = prayerPage.hasNext
        } catch {
            alertType = .error(message: error.localizedDescription)
        }
    }
    
    func deletePrayer(prayerID: Int) async {
        do {
            try await prayerUseCase.deletePrayer(prayerRequestId: prayerID)
        } catch {
            alertType = .error(message: error.localizedDescription)
        }
    }
    
    // MARK: - 내가 응답한 기도
    func refreshParticipatedPrayers() async {
        guard !isLoadingParticipatedPrayers else { return }
        isRefreshingParticipatedPrayers = true
        
        await loadParticipatedPrayers(reset: true)
        isRefreshingParticipatedPrayers = false
    }
    
    func loadParticipatedPrayers(reset: Bool) async {
        guard !isLoadingParticipatedPrayers && (reset || hasNextParticipatedPage) else { return }
        isLoadingParticipatedPrayers = true
        defer { isLoadingParticipatedPrayers = false }

        let pageToLoad = reset ? 1 : currentParticipatedPage + 1

        do {
            let responsePage = try await prayerUseCase.loadParticipatedPrayers(page: pageToLoad)

            if reset {
                participatedPrayers = responsePage.responses
            } else {
                participatedPrayers.append(contentsOf: responsePage.responses)
            }
            currentParticipatedPage = pageToLoad
            hasNextParticipatedPage = responsePage.hasNext
        } catch {
            alertType = .error(message: error.localizedDescription)
        }
    }
    
    func deletePrayerResponse(responseID: Int, prayerRequestId: Int) async {
        do {
            try await prayerUseCase.deletePrayerResponse(responseID: responseID, 
                                                         prayerRequestId: prayerRequestId)
        } catch {
            alertType = .error(message: error.localizedDescription)
        }
    }
    
    func makePrayerDetailVM(prayerRequestId: Int) -> PrayerDetailViewModel {
        return PrayerDetailViewModel(prayerUseCase: prayerUseCase,
                                     prayerRequestId: prayerRequestId)
    }
    
}
