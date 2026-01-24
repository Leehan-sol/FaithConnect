//
//  CustomBackButtonStyle.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/16.
//

import SwiftUI

struct CustomBackButtonStyle<Trailing: View>: ViewModifier {
    @Environment(\.dismiss) var dismiss
    let trailingButton: Trailing?

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }
                }

                if let trailingButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        trailingButton
                    }
                }
            }
    }
}
