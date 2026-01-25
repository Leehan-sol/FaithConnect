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
    
    private let prayerRepository: PrayerRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // TODO: - 클로저 Combine으로 변경
    var didWritePrayer: ((Prayer) -> Void)?
    
    init(prayerRepository: PrayerRepositoryProtocol) {
        self.prayerRepository = prayerRepository
    }
    
    func fetchCategories() async {
        do {
            categories = try await prayerRepository.fetchCategories()
        } catch {
            
        }
    }
    
    func writePrayer(categoryId: Int, title: String, content: String) async -> Prayer? {
        //        if categoryId == 0 {
        //            alertType = .error(message: "카테고리를 선택해 주세요.")
        //            return nil
        //        }
        //
        //        if title.isEmpty {
        //            alertType = .fieldEmpty(fieldName: "제목")
        //            return nil
        //        }
        //
        //        if content.isEmpty {
        //            alertType = .fieldEmpty(fieldName: "내용")
        //            return nil
        //        }
        //
        //        do {
        //            let prayer = try await apiClient.writePrayer(categoryID: categoryId,
        //                                                          title: title,
        //                                                          content: content)
        //            return prayer
        //        } catch {
        //            let error = error.localizedDescription
        //            alertType = .error(title: "기도 작성 실패",
        //                               message: error)
        //            return nil
        //        }
        return Prayer(id: 0,
                      userId: 0,
                      userName: "",
                      categoryId: 0,
                      categoryName: "",
                      title: "",
                      content: "",
                      createdAt: "",
                      participationCount: 0,
                      isMine: false)
    }
    
}
