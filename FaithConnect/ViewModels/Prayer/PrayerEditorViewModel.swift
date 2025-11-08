//
//  PrayerEditorViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

class PrayerEditorViewModel: ObservableObject {
    @Published var category: [PrayerCategory] = [
        PrayerCategory(categoryId: 0, categoryCode: 0, categoryName: "전체"),
        PrayerCategory(categoryId: 1, categoryCode: 1, categoryName: "건강"),
        PrayerCategory(categoryId: 2, categoryCode: 2, categoryName: "시험"),
        PrayerCategory(categoryId: 3, categoryCode: 3, categoryName: "가정"),
        PrayerCategory(categoryId: 4, categoryCode: 4, categoryName: "직장"),
        PrayerCategory(categoryId: 5, categoryCode: 5, categoryName: "감사"),
        PrayerCategory(categoryId: 6, categoryCode: 6, categoryName: "기타")
    ]
    
    let contentPlaceholder = "기도 내용을 입력하세요"
}
