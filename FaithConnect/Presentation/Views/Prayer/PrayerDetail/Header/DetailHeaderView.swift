//
//  DetailHeaderView.swift
//  FaithConnect
//
//  Created by Apple on 3/25/26.
//

import SwiftUI

struct DetailHeaderView: View {
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Text(prayer.displayLabel)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.customNavy)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.customBlue1.opacity(0.2))
                    .cornerRadius(10)

                Text(prayer.userName)
                    .font(.caption)
                    .foregroundColor(.gray)
                if prayer.role == .pastor {
                    Image(systemName: "cross.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.customPurple)
                }

                Spacer()

                if let visibility = prayer.visibility, visibility != .publicAll {
                    Text(visibility.displayName)
                        .font(.caption2)
                        .foregroundColor(.customPurple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.customPurple.opacity(0.15))
                        .cornerRadius(8)
                }

                Text(prayer.createdAt.toTimeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(prayer.title)
                .font(.title2)
            
            Text(prayer.content)
            
            Divider()
            
            Text("\(prayer.participationCount)명이 기도했어요")
                .font(.headline)
                .foregroundColor(Color(.darkGray))
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
    }
}
