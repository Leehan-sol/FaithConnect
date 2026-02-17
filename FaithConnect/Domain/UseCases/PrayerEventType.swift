//
//  PrayerEventType.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/01.
//

import Foundation

enum PrayerEventType {
    case prayerAdded(prayer: Prayer)
    case prayerUpdated(prayer: Prayer)
    case prayerDeleted(prayerId: Int)
    case responseAdded(response: MyResponse)
    case responseUpdated(response: PrayerResponse)
    case responseDeleted(responseId: Int, prayerRequestId: Int)
}
