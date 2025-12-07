//
//  MyPageItemField.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/22.
//

import SwiftUI

struct MyPageItemField: View {
    let imageName: String
    let color: Color
    let titleName: String
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding(10)
                    .foregroundColor(color)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                Text(titleName)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundColor(Color(.darkGray))
            }
            .padding(EdgeInsets(top: 10,
                                leading: 20,
                                bottom: 10,
                                trailing: 20))
        .frame(maxWidth: .infinity)
        }
    }
}



#Preview {
    MyPageItemField(imageName: "lock",
                    color: .blue,
                    titleName: "비밀번호 변경") {
        
    }.padding()
}
