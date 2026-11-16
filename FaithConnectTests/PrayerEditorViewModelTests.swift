//
//  PrayerEditorViewModelTests.swift
//  FaithConnectTests
//

import XCTest
@testable import FaithConnect

@MainActor
final class PrayerEditorViewModelTests: XCTestCase {

    private var mockPrayerUseCase: MockPrayerUseCase!

    override func setUp() {
        super.setUp()
        mockPrayerUseCase = MockPrayerUseCase()
        mockPrayerUseCase.stubbedCommunities = [
            CommunityItem(community: "JOSEPH", displayName: "요셉"),
            CommunityItem(community: "DAVID", displayName: "다윗")
        ]
    }

    override func tearDown() {
        mockPrayerUseCase = nil
        super.tearDown()
    }

    private func makeSut(userCommunity: String?) -> PrayerEditorViewModel {
        PrayerEditorViewModel(prayerUseCase: mockPrayerUseCase, isManna: true, userCommunity: userCommunity)
    }

    // 기본 공동체는 본인 공동체
    func test_fetchInitialData_manna_defaultsToUserCommunity() async {
        let sut = makeSut(userCommunity: "DAVID")

        await sut.fetchInitialData()

        XCTAssertEqual(sut.selectedCommunity, "DAVID")
        XCTAssertEqual(sut.communities.count, 2)
    }

    // 본인 공동체가 없으면 목록 첫 번째
    func test_fetchInitialData_manna_noUserCommunity_defaultsToFirst() async {
        let sut = makeSut(userCommunity: nil)

        await sut.fetchInitialData()

        XCTAssertEqual(sut.selectedCommunity, "JOSEPH")
    }

    // 목록을 못 받으면 선택 없이 오류를 띄운다
    func test_fetchInitialData_manna_failure_showsErrorAndNoSelection() async {
        mockPrayerUseCase.stubbedCommunitiesError = NSError(domain: "", code: 0,
                                                            userInfo: [NSLocalizedDescriptionKey: "네트워크 오류"])
        let sut = makeSut(userCommunity: nil)

        await sut.fetchInitialData()

        XCTAssertNil(sut.selectedCommunity)
        if case .error(_, let message) = sut.alertType {
            XCTAssertEqual(message, "네트워크 오류")
        } else {
            XCTFail("alertType이 .error가 아닙니다")
        }
    }

    // 공동체 없이 저장하면 막고 안내한다
    func test_savePrayer_manna_withoutCommunity_showsAlertAndDoesNotWrite() async {
        let sut = makeSut(userCommunity: nil)

        await sut.savePrayer(categoryId: nil, community: nil, visibility: nil, displayNameType: nil,
                             title: "제목", content: "내용")

        XCTAssertNil(mockPrayerUseCase.writePrayerCalledWith)
        if case .error(_, let message) = sut.alertType {
            XCTAssertEqual(message, "공동체를 선택해 주세요.")
        } else {
            XCTFail("alertType이 .error가 아닙니다")
        }
    }
}
