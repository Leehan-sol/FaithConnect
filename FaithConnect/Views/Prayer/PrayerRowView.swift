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
    case participated
}

struct PrayerRowView: View {
    let prayer: Prayer
    let cellType: PrayerCellType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // MARK: - Header
            if cellType != .participated {
                HStack {
                    Text(prayer.categoryName)
                        .frame(width: 40, height: 30)
                        .foregroundColor(.customNavy)
                        .background(.customBlue1.opacity(0.2))
                        .bold()
                        .font(.caption)
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    if shouldShowDateOnRight {
                        Text(prayer.createdAt.toTimeAgoDisplay())
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if cellType == .participated {
                Text("\"\(prayer.title)\"")
                    .font(.subheadline)
                    .foregroundColor(Color(.darkGray))
                    .lineLimit(1)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // MARK: - MainTitle
            Text(mainTitle)
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
                if cellType != .participated {
                    Image(systemName: "hands.clap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                
                Text(bottomText)
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

// MARK: - Extension
private extension PrayerRowView {
    var mainTitle: String {
        switch cellType {
        case .participated:
            return prayer.responses[0].message
        default:
            return prayer.title
        }
    }
    
    var bottomText: String {
        switch cellType {
        case .participated:
            return prayer.createdAt.toTimeAgoDisplay()
        default:
            return "\(prayer.participationCount)명이 기도했습니다."
        }
    }
    
    var shouldShowDateOnRight: Bool {
        cellType != .participated
    }
}

#Preview {
    PrayerRowView(prayer: Prayer(prayerRequestId: 0,
                                 prayerUserId: "",
                                 prayerUserName: "",
                                 categoryId: 0,
                                 categoryName: "건강",
                                 title: "제목",
                                 content: "내용",
                                 createdAt: "날짜",
                                 participationCount: 0,
                                 responses: [Response(prayerResponseId: 0, prayerRequestId: "", message: "응답", createdAt: "")],
                                 hasParticipated: false),
                  cellType: .others)
        .padding()
}

