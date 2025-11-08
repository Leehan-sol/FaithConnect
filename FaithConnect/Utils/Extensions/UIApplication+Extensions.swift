//
//  UIApplication+Extensions.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

extension UIApplication {
    // 키보드 내리기
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
