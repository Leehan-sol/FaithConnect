//
//  CustomBackButtonStyle.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/16.
//

import SwiftUI

struct CustomBackButtonStyle: ViewModifier {
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                        .foregroundColor(.black)
                    }
                }
            }
    }
}


