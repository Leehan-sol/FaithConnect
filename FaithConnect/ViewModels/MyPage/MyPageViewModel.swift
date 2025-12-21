//
//  MyPageViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

class MyPageViewModel: ObservableObject {
    let apiService: APIServiceProtocol
    
    init(_ apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    
    
}
