//
//  PrayerResponseRow.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/09.
//

import SwiftUI

struct PrayerResponseRow: View {
    let response: Response
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "hands.clap")
                .foregroundColor(.customNavy)
                .frame(width: 30, height: 30)
                .background(.customBlue1.opacity(0.4))
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(response.message)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(response.createdAt.toTimeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.gray)
                
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
            )
    }
}

#Preview {
    PrayerResponseRow(response: Response(prayerResponseId: 0, prayerRequestId: "", message: "어머님의 수술이 잘 되시길 기도하겠습니다. 하나님께서 함께 하실 거예요.", createdAt: "2025-11-07T12:55:00.000Z"))
        .padding()
}
