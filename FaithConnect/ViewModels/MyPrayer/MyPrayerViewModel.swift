//
//  MyPrayerViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

class MyPrayerViewModel: ObservableObject {
    @Published var writtenPrayers: [Prayer] = []
    @Published var participatedPrayers: [MyResponse] = []
    @Published var isLoadingWrittenPrayers: Bool = false
    @Published var isLoadingParticipatedPrayers: Bool = false
    
    private let apiService: APIServiceProtocol
    private var hasInitialized = false
    private var currentWrittenPage: Int = 0
    private var currentParticipatedPage: Int = 0
    private var hasNextWrittenPage: Bool = false
    private var hasNextParticipatedPage: Bool = false
    
    init(_ apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    // TODO: -
    // 1. 내 기도 조회
    // 2. 내가 기도한 기도 조회
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        await loadWrittenPrayers(page: currentWrittenPage)
        await loadParticipatedPrayers(page: currentParticipatedPage)
    }
    
    func loadWrittenPrayers(page: Int) async {
        guard !isLoadingWrittenPrayers else { return }
        isLoadingWrittenPrayers = true
        defer { isLoadingWrittenPrayers = false }
        
        do {
            let prayerPage = try await apiService.loadWrittenPrayers(page: page)
            writtenPrayers.append(contentsOf: prayerPage.prayers)
            currentWrittenPage += 1
            hasNextWrittenPage = prayerPage.hasNext
        } catch {
            print(error)
        }
    }
    
    func loadParticipatedPrayers(page: Int) async {
        guard !isLoadingParticipatedPrayers else { return }
        isLoadingParticipatedPrayers = true
        defer { isLoadingParticipatedPrayers = false }
        
        do {
            let responsePage = try await apiService.loadParticipatedPrayers(page: page)
            participatedPrayers.append(contentsOf: responsePage.responses)
            currentParticipatedPage += 1
            hasNextParticipatedPage = responsePage.hasNext
        } catch {
            print(error)
        }
    }
    
    func makePrayerDetailVM(prayer: Prayer) -> PrayerDetailViewModel {
        return PrayerDetailViewModel(apiService,
                                     prayerRequestId: prayer.id)
    }
    
}
