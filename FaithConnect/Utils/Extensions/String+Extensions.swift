//
//  String+Extensions.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/02.
//

import Foundation

extension String {
    func toTimeAgoDisplay() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: self) else {
            return self
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .day, .hour, .minute], from: date, to: now)
        
        if let day = components.day {
            switch day {
            case 0:
                // 오늘 내
                if let hour = components.hour, hour >= 1 {
                    return "\(hour)시간 전"
                } else if let minute = components.minute, minute >= 1 {
                    return "\(minute)분 전"
                } else {
                    return "방금 전"
                }
                
            case 1:
                return "어제"
            case 2...6:
                return "\(day)일 전"
            case 7:
                return "일주일 전"
            default:
                let outputFormatter = DateFormatter()
                if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
                    outputFormatter.dateFormat = "MM-dd"
                } else {
                    outputFormatter.dateFormat = "yy-MM-dd"
                }
                return outputFormatter.string(from: date)
            }
        }
        
        return "방금 전"
    }
}
