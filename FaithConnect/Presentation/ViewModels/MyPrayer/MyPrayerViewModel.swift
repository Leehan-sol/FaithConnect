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
    @Published var alertType: AlertType? = nil
    
    private let apiClient: APIClientProtocol
    private var hasInitialized = false
    private var currentWrittenPage: Int = 1
    private var currentParticipatedPage: Int = 1
    private var hasNextWrittenPage: Bool = false
    private var hasNextParticipatedPage: Bool = false
    
    init(_ apiClient: APIClientProtocol) {
        self.apiClient = apiClient
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
        guard !isLoadingWrittenPrayers else { return }
        isLoadingWrittenPrayers = true
        defer { isLoadingWrittenPrayers = false }
        
        let pageToLoad = reset ? 1 : currentWrittenPage + 1
        
        do {
            let prayerPage = try await apiClient.loadWrittenPrayers(page: pageToLoad)
            
            if reset {
                writtenPrayers = prayerPage.prayers
            } else {
                writtenPrayers.append(contentsOf: prayerPage.prayers)
            }
            currentWrittenPage = pageToLoad
            hasNextWrittenPage = prayerPage.hasNext
        } catch {
            print("내가 올린 기도 로드 실패: \(error)")
        }
    }
    
    func deletePrayer(prayerID: Int) async {
        do {
            print("삭제 API 호출")
            try await apiClient.deletePrayer(prayerRequestId: prayerID)
            var writtenPrayers = writtenPrayers
            writtenPrayers.removeAll { $0.id == prayerID }
            self.writtenPrayers = writtenPrayers
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제", message: error)
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
            let responsePage = try await apiClient.loadParticipatedPrayers(page: pageToLoad)
            
            if reset {
                participatedPrayers = responsePage.responses
            } else {
                participatedPrayers.append(contentsOf: responsePage.responses)
            }
            currentParticipatedPage = pageToLoad
            hasNextParticipatedPage = responsePage.hasNext
        } catch {
            print("내가 올린 기도 로드 실패: \(error)")
        }
    }
    
    func deletePrayerResponse(responseID: Int) async {
        do {
            print("응답 삭제 API 호출")
            try await apiClient.deletePrayerResponse(responseID: responseID)
            var participatedPrayers = participatedPrayers
            participatedPrayers.removeAll { $0.id == responseID }
            self.participatedPrayers = participatedPrayers
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제", message: error)
        }
    }
    
    func makePrayerDetailVM(prayerRequestId: Int) -> PrayerDetailViewModel {
        return PrayerDetailViewModel(apiClient,
                                     prayerRequestId: prayerRequestId)
    }
    
}
