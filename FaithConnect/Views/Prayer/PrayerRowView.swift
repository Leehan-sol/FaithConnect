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
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Participated 상단 타이틀
            if cellType == .participated {
                Text("\"\(prayer.title)\"")
                    .font(.subheadline)
                    .foregroundColor(Color(.darkGray))
                    .lineLimit(1)
                    .padding(.trailing, 20)
            }
            
            // MARK: - 메인 타이틀 줄
            HStack {
                Text(mainTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                if shouldShowDateOnRight {
                    Text(prayer.createdAt.toTimeAgoDisplay())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // MARK: - 본문 (others 전용)
            if cellType == .others {
                Text(prayer.content)
                    .font(.subheadline)
                    .foregroundColor(Color(.darkGray))
                    .lineLimit(3)
            }
            
            // MARK: - 하단
            HStack {
                if cellType != .participated {
                    Image(systemName: "hands.clap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                
                Text(bottomText)
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

// MARK: - Extension
private extension PrayerRowView {
    var mainTitle: String {
        switch cellType {
        case .participated:
            return prayer.myResponse
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
