//
//  MyResponseRowView.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/28.
//

import SwiftUI

struct MyResponseRowView: View {
    let response: MyResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("\"\(response.prayerRequestTitle)\"")
                .font(.subheadline)
                .foregroundColor(Color(.darkGray))
                .lineLimit(1)

            Text(response.message)
                .font(.headline)
                .lineLimit(1)
            
            Text(response.createdAt.toTimeAgoDisplay())
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        
    }
}

#Preview {
    MyResponseRowView(response: MyResponse(id: 0,
                                           prayerResponseId: 0,
                                           prayerRequestTitle: "제목",
                                           categoryId: 0,
                                           categoryName: "건강",
                                           message: "내용",
                                           createdAt: "날짜"))
        .padding()
}

