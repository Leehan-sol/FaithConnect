//
//  PrayerRowView.swift
//  FaithConnect
//
//  Created by Apple on 11/4/25.
//

import SwiftUI

struct PrayerRowView: View {
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(prayer.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(prayer.createdAt.toTimeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(prayer.content)
                .font(.subheadline)
                .foregroundColor(Color(.darkGray))
                .lineLimit(3)
            
            HStack {
                Image(systemName: "hands.clap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                
                Text("\(prayer.participationCount)명이 기도했습니다.")
                    .font(.caption)
            }
            .foregroundColor(.gray)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    }
}
