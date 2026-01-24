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
    
    private let apiClient: APIClientProtocol
    private let prayerRequestId: Int
    private var hasInitialized = false
    
    init(_ apiClient: APIClientProtocol, prayerRequestId: Int) {
        self.apiClient = apiClient
        self.prayerRequestId = prayerRequestId
    }
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        do {
            let prayer = try await apiClient.loadPrayerDetail(prayerRequestID: prayerRequestId)
            self.prayer = prayer
        } catch {
            print(error)
        }
        
    }
    
    func deletePrayer() async -> Int? {
        do {
            print("삭제 API 호출")
            guard let id = prayer?.id else { return nil }
            try await apiClient.deletePrayer(prayerRequestId: id)
            return id
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제 실패",
                               message: error)
            return nil
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
            let response = try await apiClient.writePrayerResponse(prayerRequsetID: id,
                                                                   message: message)
            guard var prayer = prayer else { return false }
            prayer.responses?.append(response)
//            prayer.hasParticipated = true
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
            try await apiClient.deletePrayerResponse(responseID: response.id)
            
            guard var prayer = prayer else { return }
            prayer.responses?.removeAll { $0.id == response.id }
            self.prayer = prayer
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "삭제 실패",
                               message: error)
        }
    }
    
}
