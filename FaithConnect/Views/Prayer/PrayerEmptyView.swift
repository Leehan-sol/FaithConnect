//
//  PrayerEmptyView.swift
//  FaithConnect
//
//  Created by Apple on 12/24/25.
//

import SwiftUI

struct PrayerEmptyView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image(systemName: "hands.clap")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(.systemGray4))
                .padding(.bottom)
            
            Text("아직 기도가 없습니다")
                .font(.subheadline)
                
            Text("첫 번째 기도를 작성해보세요")
                .font(.footnote)
            
            Spacer()
        }
        .foregroundColor(Color(.darkGray))
    }
}

#Preview {
    PrayerEmptyView()
}
