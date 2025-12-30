//
//  MyPrayerViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

@MainActor
class MyPrayerViewModel: ObservableObject {
    @Published var writtenPrayers: [Prayer] = []
    @Published var participatedPrayers: [MyResponse] = []
    @Published var isLoadingWrittenPrayers: Bool = false
    @Published var isRefreshingWrittenPrayers: Bool = false
    @Published var isLoadingParticipatedPrayers: Bool = false
    @Published var isRefreshingParticipatedPrayers: Bool = false
    
    private let apiClient: APIClientProtocol
    private var hasInitialized = false
    private var currentWrittenPage: Int = 0
    private var currentParticipatedPage: Int = 0
    private var hasNextWrittenPage: Bool = false
    private var hasNextParticipatedPage: Bool = false
    
    init(_ apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        await loadWrittenPrayers(page: currentWrittenPage)
        await loadParticipatedPrayers(page: currentParticipatedPage)
    }
    
    // MARK: - 내가 올린 기도
    func refreshWrittenPrayers() async {
        guard !isLoadingWrittenPrayers else { return }
        isRefreshingWrittenPrayers = true
        
        await loadWrittenPrayers(page: 0)
        isRefreshingWrittenPrayers = false
    }
    
    func loadWrittenPrayers(page: Int) async {
        guard !isLoadingWrittenPrayers else { return }
        isLoadingWrittenPrayers = true
        defer { isLoadingWrittenPrayers = false }
        
        do {
            let prayerPage = try await apiClient.loadWrittenPrayers(page: page)
            writtenPrayers.append(contentsOf: prayerPage.prayers)
            currentWrittenPage += 1
            hasNextWrittenPage = prayerPage.hasNext
        } catch {
            print(error)
        }
    }
    
    // MARK: - 내가 응답한 기도
    func refreshParticipatedPrayers() async {
        guard !isLoadingParticipatedPrayers else { return }
        isRefreshingParticipatedPrayers = true
        
        await loadParticipatedPrayers(page: 0)
        isRefreshingParticipatedPrayers = false
    }
    
    func loadParticipatedPrayers(page: Int) async {
        guard !isLoadingParticipatedPrayers else { return }
        isLoadingParticipatedPrayers = true
        defer { isLoadingParticipatedPrayers = false }
        
        do {
            let responsePage = try await apiClient.loadParticipatedPrayers(page: page)
            participatedPrayers.append(contentsOf: responsePage.responses)
            currentParticipatedPage += 1
            hasNextParticipatedPage = responsePage.hasNext
        } catch {
            print(error)
        }
    }
    
    func makePrayerDetailVM(prayerRequestId: Int) -> PrayerDetailViewModel {
        return PrayerDetailViewModel(apiClient,
                                     prayerRequestId: prayerRequestId)
    }
    
}
