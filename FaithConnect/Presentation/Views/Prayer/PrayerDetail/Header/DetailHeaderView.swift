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
                Text(prayer.categoryName)
                    .frame(width: 40, height: 30)
                    .foregroundColor(.customNavy)
                    .background(.customBlue1.opacity(0.2))
                    .bold()
                    .font(.caption)
                    .cornerRadius(10)
                
                Text(prayer.createdAt.toTimeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
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
