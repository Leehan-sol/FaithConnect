//
//  PrayerUseCaseTests.swift
//  FaithConnectTests
//

import XCTest
import Combine
@testable import FaithConnect

final class PrayerUseCaseTests: XCTestCase {

    private var sut: PrayerUseCase!
    private var mockRepository: MockPrayerRepository!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockPrayerRepository()
        sut = PrayerUseCase(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - 데이터 조회

    func test_loadCategories_success_returnsEntities() async throws {
        mockRepository.stubbedCategories = [
            PrayerCategory(id: 1, categoryCode: 1, categoryName: "전체"),
            PrayerCategory(id: 2, categoryCode: 2, categoryName: "가족")
        ]

        let result = try await sut.loadCategories()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].categoryName, "전체")
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[1].categoryName, "가족")
        XCTAssertTrue(mockRepository.loadCategoriesCalled)
    }

    func test_loadCategories_failure_propagatesError() async {
        mockRepository.stubbedError = NSError(domain: "", code: 0,
                                               userInfo: [NSLocalizedDescriptionKey: "네트워크 오류"])

        do {
            _ = try await sut.loadCategories()
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertEqual(error.localizedDescription, "네트워크 오류")
        }
    }

    func test_loadPrayers_success_returnsPrayerPage() async throws {
        let prayer = Prayer(
            id: 1, userId: 10, userName: "홍길동",
            categoryId: 2, categoryName: "가족",
            title: "기도 제목", content: "기도 내용",
            createdAt: "2026-01-01", participationCount: 5,
            responses: nil, hasParticipated: false, isMine: true
        )

        mockRepository.stubbedPrayerPage = PrayerPage(
            prayers: [prayer], currentPage: 1, hasNext: true
        )

        let result = try await sut.loadPrayers(categoryID: 2, page: 1)

        XCTAssertEqual(result.prayers.count, 1)
        XCTAssertEqual(result.prayers[0].id, 1)
        XCTAssertEqual(result.prayers[0].userName, "홍길동")
        XCTAssertEqual(result.prayers[0].title, "기도 제목")
        XCTAssertEqual(result.currentPage, 1)
        XCTAssertTrue(result.hasNext)
    }

    // MARK: - 이벤트 발행

    func test_writePrayer_success_publishesPrayerAddedEvent() async throws {
        mockRepository.stubbedPrayer = Prayer(
            id: 99, userId: 1, userName: "작성자",
            categoryId: 2, categoryName: "감사",
            title: "새 기도", content: "내용",
            createdAt: "2026-03-01", participationCount: 0,
            responses: [], hasParticipated: false, isMine: true
        )

        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        _ = try await sut.writePrayer(categoryID: 2, title: "새 기도", content: "내용")

        if case .prayerAdded(let prayer) = receivedEvent {
            XCTAssertEqual(prayer.id, 99)
            XCTAssertEqual(prayer.title, "새 기도")
        } else {
            XCTFail("prayerAdded 이벤트가 발행되지 않았습니다")
        }
    }

    func test_deletePrayer_success_publishesPrayerDeletedEvent() async throws {
        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        try await sut.deletePrayer(prayerRequestId: 42)

        if case .prayerDeleted(let prayerId) = receivedEvent {
            XCTAssertEqual(prayerId, 42)
        } else {
            XCTFail("prayerDeleted 이벤트가 발행되지 않았습니다")
        }
        XCTAssertEqual(mockRepository.deletePrayerCalledWith, 42)
    }

    func test_writePrayerResponse_success_publishesResponseAddedEvent() async throws {
        mockRepository.stubbedPrayerResponse = PrayerResponse(
            id: 10, prayerRequestId: 1, userId: 1, userName: "작성자",
            message: "응원합니다", createdAt: "2026-03-01",
            isMine: true, parentResponseId: nil, replyCount: 0
        )

        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        _ = try await sut.writePrayerResponse(
            prayerRequestID: 1, message: "응원합니다",
            prayerTitle: "기도 제목", categoryId: 2, categoryName: "감사"
        )

        if case .responseAdded(let response) = receivedEvent {
            XCTAssertEqual(response.id, 10)
            XCTAssertEqual(response.prayerRequestId, 1)
            XCTAssertEqual(response.message, "응원합니다")
        } else {
            XCTFail("responseAdded 이벤트가 발행되지 않았습니다")
        }
    }

    func test_deletePrayerResponse_success_publishesResponseDeletedEvent() async throws {
        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        try await sut.deletePrayerResponse(responseID: 5, prayerRequestId: 1)

        if case .responseDeleted(let responseId, let prayerRequestId) = receivedEvent {
            XCTAssertEqual(responseId, 5)
            XCTAssertEqual(prayerRequestId, 1)
        } else {
            XCTFail("responseDeleted 이벤트가 발행되지 않았습니다")
        }
    }

    func test_updatePrayer_success_publishesPrayerUpdatedEvent() async throws {
        mockRepository.stubbedPrayer = Prayer(
            id: 1, userId: 10, userName: "홍길동",
            categoryId: 2, categoryName: "감사",
            title: "수정된 제목", content: "수정된 내용",
            createdAt: "2026-01-01", participationCount: 3,
            responses: nil, hasParticipated: false, isMine: true
        )

        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        _ = try await sut.updatePrayer(prayerRequestId: 1, categoryID: 2,
                                        title: "수정된 제목", content: "수정된 내용")

        if case .prayerUpdated(let prayer) = receivedEvent {
            XCTAssertEqual(prayer.id, 1)
            XCTAssertEqual(prayer.title, "수정된 제목")
        } else {
            XCTFail("prayerUpdated 이벤트가 발행되지 않았습니다")
        }
    }
}
