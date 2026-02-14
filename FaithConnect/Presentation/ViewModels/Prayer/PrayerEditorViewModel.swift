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
    let prayer: Prayer?

    var isEditMode: Bool { prayer != nil }

    init(prayerUseCase: PrayerUseCaseProtocol, prayer: Prayer? = nil) {
        self.prayerUseCase = prayerUseCase
        self.prayer = prayer
    }
    
    func fetchCategories() async {
        do {
            let allCategories = try await prayerUseCase.loadCategories()
            categories = allCategories.filter { $0.categoryCode != 1 }
        } catch {
            alertType = .error(message: error.localizedDescription)
        }
    }
    
    func savePrayer(categoryId: Int, title: String, content: String) async {
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
            if let prayer {
                let _ = try await prayerUseCase.updatePrayer(prayerRequestId: prayer.id,
                                                             categoryID: categoryId,
                                                             title: title,
                                                             content: content)
            } else {
                let _ = try await prayerUseCase.writePrayer(categoryID: categoryId,
                                                            title: title,
                                                            content: content)
            }
        } catch {
            let failTitle = isEditMode ? "기도 수정 실패" : "기도 작성 실패"
            alertType = .error(title: failTitle,
                               message: error.localizedDescription)
        }
    }

}
