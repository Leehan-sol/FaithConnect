//
//  PrayerEditorViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

@MainActor
class PrayerEditorViewModel: ObservableObject {
    @Published var alertType: PrayerAlert? = nil
    
    private let apiClient: APIClientProtocol
    var didWritePrayer: ((Prayer) -> Void)?
    
    init(_ apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func writePrayer(categoryId: Int, title: String, content: String) async -> Prayer? {
        if categoryId == 0 {
            alertType = .categoryNotSelected
            return nil
        }
        
        if title.isEmpty {
            alertType = .fieldEmpty(fieldName: "제목")
            return nil
        }
        
        if content.isEmpty {
            alertType = .fieldEmpty(fieldName: "내용")
            return nil
        }
        
        do {
            let prayer = try await apiClient.writePrayer(categoryId: categoryId, 
                                                          title: title,
                                                          content: content)
            return prayer
        } catch {
            let error = error.localizedDescription
            alertType = .writeError(message: error)
            return nil
        }
    }
    
}
