//
//  PrayerBottomSheetType.swift
//  FaithConnect
//
//  Created by Apple on 3/23/26.
//

enum PrayerBottomSheetType: Identifiable {
    case create
    case edit(PrayerResponse)
    
    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let r): return "edit-\(r.id)"
        }
    }
    
    var editingResponse: PrayerResponse? {
        switch self {
        case .create: return nil
        case .edit(let r): return r
        }
    }
}
