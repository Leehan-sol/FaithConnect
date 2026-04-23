//
//  UnavailableHeaderView.swift
//  FaithConnect
//
//  Created by Apple on 3/25/26.
//

import SwiftUI

struct UnavailableHeaderView: View {
    let participationCount: Int
    var contentStatus: ContentStatus = .deleted

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: contentStatus == .blocked ? "nosign" : "trash.slash")
                .font(.system(size: 28))
                .foregroundColor(.gray)
            Text(contentStatus == .blocked ? "차단된 사용자의 기도입니다" : "삭제된 기도입니다")
                .font(.headline)
                .foregroundColor(.gray)
            Text(contentStatus == .blocked
                 ? "차단된 사용자의 게시물입니다."
                 : "이 기도는 작성자에 의해 삭제되었습니다.")
                .font(.subheadline)
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
