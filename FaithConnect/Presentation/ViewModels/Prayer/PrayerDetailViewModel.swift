//
//  PrayerDetailViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

@MainActor
class PrayerDetailViewModel: ObservableObject {
    @Published var prayer: Prayer?
    @Published var alertType: AlertType? = nil
    
    private let prayerUseCase: PrayerUseCaseProtocol
    private let prayerRequestId: Int
    private var hasInitialized = false
    
    init(prayerUseCase: PrayerUseCaseProtocol, prayerRequestId: Int) {
        self.prayerUseCase = prayerUseCase
        self.prayerRequestId = prayerRequestId
    }
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        await loadPrayerDetail()
    }
    
    func refresh() async {
        await loadPrayerDetail()
    }
    
    private func loadPrayerDetail() async {
        do {
            let prayer = try await prayerUseCase.loadPrayerDetail(prayerRequestID: prayerRequestId)
            self.prayer = prayer
        } catch {
            alertType = .error(title: "불러오기 실패",
                               message: error.localizedDescription)
        }
    }
    
    func deletePrayer() async {
        do {
            print("삭제 API 호출")
            guard let id = prayer?.id else { return }
            try await prayerUseCase.deletePrayer(prayerRequestId: id)
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제 실패",
                               message: error)
        }
    }
    
    func writePrayerResponse(message: String) async -> Bool {
        if message.isEmpty {
            alertType = .fieldEmpty(fieldName: "응답")
        }
        
        guard let id = prayer?.id else {
            return false
        }
        
        do {
            print("기도 응답 API 호출")
            let response = try await prayerUseCase.writePrayerResponse(prayerRequsetID: id,
                                                                          message: message)
            guard var prayer = prayer else { return false }
            prayer.responses?.insert(response, at: 0)
            prayer.participationCount += 1
            self.prayer = prayer
            return true
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "응답 작성 실패",
                               message: error)
            return false
        }
    }
    
    func deletePrayerResponse(response: PrayerResponse) async {
        do {
            print("응답 삭제 API 호출")
            try await prayerUseCase.deletePrayerResponse(responseID: response.id)
            
            guard var prayer = prayer else { return }
            prayer.responses?.removeAll { $0.id == response.id }
            prayer.participationCount -= 1
            self.prayer = prayer
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제 실패",
                               message: error)
        }
    }
    
}
