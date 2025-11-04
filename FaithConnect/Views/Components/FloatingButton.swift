//
//  FloatingButton.swift
//  FaithConnect
//
//  Created by Apple on 11/4/25.
//

import SwiftUI

struct FloatingButton: View {
    var action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
                .frame(width: 60, height: 60)
                .background(Color.customBlue1.opacity(0.8))
                .cornerRadius(30)
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                .padding(.bottom, 20)
                .padding(.trailing, 20)
            }
        }
    }
}
