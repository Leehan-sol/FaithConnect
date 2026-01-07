//
//  LabeldTextField.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import SwiftUI

struct LabeledTextField: View {
    @State var secureState: Bool = true
    
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
                Group {
                    if secureState {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    Button(action: {
                        secureState.toggle()
                    }) {
                        Image(systemName: secureState ? "eye" : "eye.slash")
                            .foregroundColor(Color(.darkGray))
                    }
                        .padding(),
                    alignment: .trailing
                )
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


struct IntLabeledTextField: View {
    let title: String
    var placeholder: String
    @Binding var value: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .bold()
            
            TextField(placeholder, value: $value, format: .number)
                .keyboardType(.numberPad)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}


#Preview {
    LabeledTextField(title: "타이틀",
                     placeholder: "텍스트홀더 입력하세요.",
                     isSecure: true,
                     text: .constant(""))
    .padding()
}
