//
//  LoadingDialogView.swift
//  FaithConnect
//
//  Created by Apple on 1/7/26.
//

import SwiftUI

struct LoadingDialogView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                Image(systemName: "figure.2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.customBlue1)
                
                Text("연결 중...")
                    .font(.headline)
                    .foregroundColor(.customBlue1)
            }
            .symbolEffect(.pulse, options: .repeating)
            .padding(30)
            .background(.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
    
}

#Preview {
    LoadingDialogView()
}
