//
//  PrayerEditorViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

enum PrayerEditAlert: Identifiable {
    case categoryNotSelected
    case fieldEmpty(fieldName: String)
    case writeError(message: String)
    
    var id: Int {
        switch self {
        case .categoryNotSelected: return 0
        case .fieldEmpty: return 1
        case .writeError: return 2
        }
    }
    
    var title: String {
        switch self {
        case .categoryNotSelected, .fieldEmpty:
            return "입력 오류"
        case .writeError:
            return "기도 작성 실패"
        }
    }
    
    var message: String {
        switch self {
        case .categoryNotSelected:
            return "카테고리를 선택해 주세요."
        case .fieldEmpty(let message):
            return "\(message)을 입력해주세요."
        case .writeError(let message):
            return message
        }
    }
}

class PrayerEditorViewModel: ObservableObject {
    private let apiService: APIServiceProtocol
    @Published var alertType: PrayerEditAlert? = nil
    
    var didWritePrayer: ((Prayer) -> Void)?
    
    init(_ apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    @MainActor
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
            let prayer = try await apiService.writePrayer(categoryId: categoryId, title: title, content: content)
            return prayer
        } catch {
            let error = error.localizedDescription
            alertType = .writeError(message: error)
            return nil
        }
    }
    
}
