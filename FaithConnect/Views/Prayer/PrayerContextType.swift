//
//  PrayerContextType.swift
//  FaithConnect
//
//  Created by Apple on 12/30/25.
//

enum PrayerContextType {
    case prayer
    case response
    
    var navigationTitle: String {
        switch self {
        case .prayer:
            return "내가 올린 기도"
        case .response:
            return "내가 기도한 기도"
        }
    }
}
