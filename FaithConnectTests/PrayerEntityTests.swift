//
//  PrayerEntityTests.swift
//  FaithConnectTests
//

import XCTest
@testable import FaithConnect

final class PrayerEntityTests: XCTestCase {

    private func makePrayer(community: String?, communityName: String?, categoryName: String?) -> Prayer {
        Prayer(id: 1, userId: 1, userName: "테스트",
               categoryId: nil, categoryName: categoryName,
               community: community, communityName: communityName,
               visibility: nil, displayNameType: nil, role: nil,
               title: "제목", content: "내용", createdAt: "2026-01-01",
               participationCount: 0, responses: nil, hasParticipated: false, isMine: false)
    }

    func test_displayLabel_prefersCommunityName() {
        let prayer = makePrayer(community: "JOSEPH", communityName: "요셉", categoryName: "가족")
        XCTAssertEqual(prayer.displayLabel, "요셉")
    }

    func test_displayLabel_noCommunityName_fallsBackToCode() {
        let prayer = makePrayer(community: "SAMUEL", communityName: nil, categoryName: nil)
        XCTAssertEqual(prayer.displayLabel, "SAMUEL")
    }

    func test_displayLabel_noCommunity_usesCategoryName() {
        let prayer = makePrayer(community: nil, communityName: nil, categoryName: "가족")
        XCTAssertEqual(prayer.displayLabel, "가족")
    }

    func test_displayLabel_emptyCommunity_usesCategoryName() {
        let prayer = makePrayer(community: "", communityName: nil, categoryName: "가족")
        XCTAssertEqual(prayer.displayLabel, "가족")
    }
}
