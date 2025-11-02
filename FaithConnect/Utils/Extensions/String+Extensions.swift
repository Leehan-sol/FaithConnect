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
        let components = calendar.dateComponents([.year, .second, .minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 1 {
            let outputFormatter = DateFormatter()
            if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
                outputFormatter.dateFormat = "MM-dd"
            } else {
                outputFormatter.dateFormat = "yy-MM-dd"
            }
            return outputFormatter.string(from: date)
        } else if let day = components.day, day == 1 {
            return "어제"
        } else if let hour = components.hour, hour >= 1 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute >= 1 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
}
