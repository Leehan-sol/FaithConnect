//
//  PrayerRowView.swift
//  FaithConnect
//
//  Created by Apple on 11/4/25.
//

import SwiftUI

enum PrayerCellType {
    case mine
    case others
}

struct PrayerRowView: View {
    let prayer: Prayer
    let cellType: PrayerCellType

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            // MARK: - Header
            HStack {
                Text(prayer.categoryName)
                    .frame(width: 40, height: 30)
                    .foregroundColor(.customNavy)
                    .background(.customBlue1.opacity(0.2))
                    .bold()
                    .font(.caption)
                    .cornerRadius(10)

                Spacer()

                Text(prayer.createdAt.toTimeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            // MARK: - Title
            Text(prayer.title)
                .font(.headline)
                .lineLimit(1)

            // MARK: - Content
            if cellType == .others {
                Text(prayer.content)
                    .font(.subheadline)
                    .foregroundColor(Color(.darkGray))
                    .lineLimit(3)
            }

            // MARK: - Bottom
            HStack {
                Image(systemName: "hands.clap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)

                Text("\(prayer.participationCount)명이 기도했습니다.")
                    .font(.caption2)
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

#Preview {
    PrayerRowView(prayer: Prayer(id: 0,
                                 userId: 0,
                                 userName: "",
                                 categoryId: 0,
                                 categoryName: "건강",
                                 title: "제목",
                                 content: "내용",
                                 createdAt: "날짜",
                                 participationCount: 0,
                                 responses: [PrayerResponse(id: 0,
                                                      prayerRequestId: 0,
                                                      message: "응답",
                                                      createdAt: "")],
                                 hasParticipated: false),
                  cellType: .others)
        .padding()
}

