//
//  PrayerEmptyView.swift
//  FaithConnect
//
//  Created by Apple on 12/24/25.
//

import SwiftUI

struct PrayerEmptyView: View {
    let prayerContextType: PrayerContextType
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image(systemName: "hands.clap")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(.systemGray4))
                .padding(.bottom)
            
            if prayerContextType == .prayer {
                Text("아직 기도가 없어요")
                    .font(.subheadline)
                    
                Text("첫 번째 기도를 작성해보세요")
                    .font(.footnote)
            }
            
            if prayerContextType == .response {
                Text("아직 함께한 기도가 없어요")
                    .font(.subheadline)
                    
                Text("다른 사람의 기도에 함께 기도해보세요")
                    .font(.footnote)
            }
            
            Spacer()
        }
        .foregroundColor(Color(.darkGray))
    }
}

#Preview {
    PrayerEmptyView(prayerContextType: .prayer)
}
