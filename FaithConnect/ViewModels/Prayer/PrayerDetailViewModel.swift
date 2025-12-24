//
//  PrayerDetailViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

class PrayerDetailViewModel: ObservableObject {
    @Published var prayer: Prayer
    let contentPlaceholder = "이 기도제목에 응답하는 메세지를 작성해주세요. \r \r익명으로 전송되며, 작성자에게 알림이 전달됩니다."
    
    init(prayer: Prayer) {
        self.prayer = prayer
    }
    
    // TODO: -
    // 1. 기도 상세 조회
    // 2. 기도 응답 작성
    
}
