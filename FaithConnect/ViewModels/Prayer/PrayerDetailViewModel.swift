//
//  PrayerDetailViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

class PrayerDetailViewModel: ObservableObject {
    @Published var prayer: Prayer?
    @Published var alertType: PrayerAlert? = nil
    
    private let apiService: APIServiceProtocol
    private let prayerRequestId: Int
    private var hasInitialized = false
    
    init(_ apiService: APIServiceProtocol, prayerRequestId: Int) {
        self.apiService = apiService
        self.prayerRequestId = prayerRequestId
    }
    
    // TODO: -
    // 1. 기도 상세 조회 v
    // 2. 기도 삭제
    // 3. 기도 응답 작성 v
    // 4. 기도 응답 삭제
    
    func initializeIfNeeded() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        do {
            let prayer = try await apiService.loadPrayerDetail(prayerRequestId: prayerRequestId)
            self.prayer = prayer
        } catch {
            print(error)
        }
        
    }
    
    func deletePrayer() async {
        do {
            print("삭제 API 호출")
            guard let id = self.prayer?.id else { return }
            try await apiService.deletePrayer(prayerRequestId: id)
        } catch {
            let error = error.localizedDescription
            alertType = .deleteFailure(message: error)
        }
    }
    
    func writePrayerResponse(message: String) async -> Bool {
        do {
            print("기도 응답 API 호출")
            if message.isEmpty {
                alertType = .fieldEmpty(fieldName: "응답")
            }
            
            guard let id = self.prayer?.id else {
                return false
            }
            
            let response = try await apiService.writePrayerResponse(prayerRequsetId: id,
                                                     message: message)
            
            self.prayer?.responses?.append(response)
            self.prayer?.hasParticipated = true
            if let responses = self.prayer?.responses {
                   for (index, resp) in responses.enumerated() {
                       print("responses[\(index)]: \(resp.message)")
                   }
               }
            
            return true
        } catch {
            let error = error.localizedDescription
            alertType = .writeError(message: error)
            return false
        }
    }
    
    func deletePrayerResponse(response: PrayerResponse) async {
        do {
            print("응답 삭제 API 호출")
//            guard let id = self.prayer?.id else { return }
         //   try await apiService.deletePrayerResponse(prayerRequestId: id)
        } catch {
            let error = error.localizedDescription
            alertType = .deleteFailure(message: error)
        }
    }
    
}
