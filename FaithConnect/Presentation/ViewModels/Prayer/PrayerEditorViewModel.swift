//
//  PrayerEditorViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation
import Combine

@MainActor
class PrayerEditorViewModel: ObservableObject {
    @Published var categories: [PrayerCategory] = []
    @Published var alertType: AlertType? = nil
    
    private let prayerUseCase: PrayerUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    init(prayerUseCase: PrayerUseCaseProtocol) {
        self.prayerUseCase = prayerUseCase
    }
    
    func fetchCategories() async {
        // TODO: - '전체' 카테고리 제거
        do {
            categories = try await prayerUseCase.loadCategories()
        } catch {
            
        }
    }
    
    func writePrayer(categoryId: Int, title: String, content: String) async {
        if categoryId == 0 {
            alertType = .error(message: "카테고리를 선택해 주세요.")
            return
        }
        
        if title.isEmpty {
            alertType = .fieldEmpty(fieldName: "제목")
            return
        }
        
        if content.isEmpty {
            alertType = .fieldEmpty(fieldName: "내용")
            return
        }
        
        do {
            let _ = try await prayerUseCase.writePrayer(categoryID: categoryId,
                                                                title: title,
                                                                content: content)
        } catch {
            let error = error.localizedDescription
            alertType = .error(title: "기도 작성 실패",
                               message: error)
            return
        }
    }
    
}
