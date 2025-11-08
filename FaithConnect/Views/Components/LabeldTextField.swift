//
//  LabeldTextField.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct LabeledTextField: View {
    let title: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .bold()
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    LabeledTextField(title: "타이틀", placeholder: "입력하세요.", text: .constant("Initial Value"))
        .padding()
}
