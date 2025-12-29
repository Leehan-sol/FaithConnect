//
//  MyPageViewModel.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

class MyPageViewModel: ObservableObject {
    let apiClient: APIClientProtocol
    
    init(_ apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    
    
}
