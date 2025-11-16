//
//  ActionButton.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/08.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(foregroundColor)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
        }
    }
}

#Preview {
    ActionButton(title: "버튼", 
                 foregroundColor: .white,
                 backgroundColor: .customBlue1) {}
        .padding()
}
