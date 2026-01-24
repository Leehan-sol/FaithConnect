//
//  InfoBoxView.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/14.
//

import SwiftUI

struct InfoBoxView: View {
    let messages: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(messages, id: \.self) { message in
                Text(message)
            }
        }
        .font(.caption)
        .padding(EdgeInsets(top: 18, leading: 8, bottom: 18, trailing: 0))
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.customNavy)
        .background(Color(.customBlue1).opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    InfoBoxView(
        messages: [
            "• 교번과 이름은 인증 목적으로만 사용되며 익명성이 보장됩니다.",
            "• 모든 기도제목과 응답은 익명으로 처리됩니다.",
            "• 개인정보는 안전하게 보호됩니다."
        ])
    .padding()
}
