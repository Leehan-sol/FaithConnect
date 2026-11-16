//
//  TabHeaderView.swift
//  FaithConnect
//

import SwiftUI

// 탭 루트 화면 공통 상단 줄. 기본 큰 제목 대신 써서 탭마다 높이·여백을 맞춘다.
struct TabHeaderView<Trailing: View>: View {
    let title: String
    var showsLogo: Bool = false
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 8) {
            if showsLogo {
                Image("heartIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }

            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Spacer(minLength: 8)

            trailing()
        }
        .frame(height: 28)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

extension TabHeaderView where Trailing == EmptyView {
    init(title: String, showsLogo: Bool = false) {
        self.init(title: title, showsLogo: showsLogo) { EmptyView() }
    }
}
