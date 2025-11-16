//
//  View+Extensions.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/16.
//

import SwiftUI

extension View {
    func customBackButtonStyle() -> some View {
        self.modifier(CustomBackButtonStyle())
    }
}
