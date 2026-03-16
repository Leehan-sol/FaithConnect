//
//  DeepLinkManager.swift
//  FaithConnect
//
//  Created by hansol on 2026/03/16.
//

import Foundation

enum DeepLinkDestination: Equatable {
    case prayerDetail(prayerRequestId: Int)
}

@MainActor
class DeepLinkManager: ObservableObject {
    @Published var pendingDestination: DeepLinkDestination?

    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let prayerRequestId = parsePrayerRequestId(from: userInfo) else {
            print("prayerRequestId 파싱 실패: \(userInfo)")
            return
        }
        pendingDestination = .prayerDetail(prayerRequestId: prayerRequestId)
    }

    func clearDestination() {
        pendingDestination = nil
    }
    
    private func parsePrayerRequestId(from userInfo: [AnyHashable: Any]) -> Int? {
        if let idString = userInfo["prayerRequestId"] as? String,
           let id = Int(idString) {
            return id
        }
        return userInfo["prayerRequestId"] as? Int
    }
}
