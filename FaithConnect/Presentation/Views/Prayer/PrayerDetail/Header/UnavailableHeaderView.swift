//
//  UnavailableHeaderView.swift
//  FaithConnect
//
//  Created by Apple on 3/25/26.
//

import SwiftUI

struct UnavailableHeaderView: View {
    let content: String
    let participationCount: Int

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 28))
                .foregroundColor(.gray)
            Text(content)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)

        Divider()
            .padding(.horizontal, 20)

        Text("\(participationCount)명이 기도했어요")
            .font(.headline)
            .foregroundColor(Color(.darkGray))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
    }
}
