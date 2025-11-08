//
//  PrayerDetailViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import Foundation

class PrayerDetailViewModel: ObservableObject {
    @Published var prayer: Prayer
    
    init(prayer: Prayer) {
        self.prayer = prayer
    }
    
    // TODO: -
    // 1. 기도 상세 조회
    //
    
    
}
