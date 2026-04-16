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

    // MARK: - DTO → Entity Mapping
    
    // 1. mockRepository.stubbedCategories에 CategoryResponse DTO 2개 세팅
    // 2. sut.loadCategories() 호출
    // 3. 반환된 PrayerCategory Entity의 id, categoryName이 DTO와 일치하는지 검증
    func test_loadCategories_success_mapsDTOToEntity() async throws {
        mockRepository.stubbedCategories = [
            CategoryResponse(categoryId: 1, categoryCode: 1, categoryName: "전체"),
            CategoryResponse(categoryId: 2, categoryCode: 2, categoryName: "가족")
        ]

        let result = try await sut.loadCategories()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].categoryName, "전체")
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[1].categoryName, "가족")
        XCTAssertTrue(mockRepository.loadCategoriesCalled)
    }
    
    // 1. mockRepository.stubbedError 값 할당
    // 2. sut.loadCategories() 호출
    // 3. stubbedError != nil → throws error
    // 4. error.localizedDescription == "네트워크 오류"
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
    
    // 1. mockRepository.stubbedPrayerList에 PrayerListResponse DTO 세팅
    // 2. sut.loadPrayers() 호출
    // 3. 반환된 PrayerPage의 prayers(id, userName, title), currentPage, hasNext 검증
    func test_loadPrayers_success_mapsDTOToPrayerPage() async throws {
        let prayerDetail = PrayerDetailResponse(
            prayerRequestId: 1,
            prayerUserId: 10,
            prayerUserName: "홍길동",
            categoryId: 2,
            categoryName: "가족",
            title: "기도 제목",
            content: "기도 내용",
            createdAt: "2026-01-01",
            participationCount: 5,
            responses: nil,
            hasParticipated: false,
            isMine: true,
            errorCode: nil,
            status: nil
        )

        mockRepository.stubbedPrayerList = PrayerListResponse(
            prayerRequests: [prayerDetail],
            currentPage: 1,
            totalPages: 3,
            totalElements: 25,
            pageSize: 10,
            hasNext: true,
            hasPrevious: false,
            errorCode: nil,
            status: nil
        )

        let result = try await sut.loadPrayers(categoryID: 2, page: 1)

        XCTAssertEqual(result.prayers.count, 1)
        XCTAssertEqual(result.prayers[0].id, 1)
        XCTAssertEqual(result.prayers[0].userName, "홍길동")
        XCTAssertEqual(result.prayers[0].title, "기도 제목")
        XCTAssertEqual(result.currentPage, 1)
        XCTAssertTrue(result.hasNext)
    }

    // MARK: - Event Publishing
    
    // 1. mockRepository.stubbedPrayerWrite에 PrayerWriteResponse 세팅
    // 2. eventPublisher 구독
    // 3. sut.writePrayer() 호출
    // 4. .prayerAdded 이벤트 발행, prayer.id == 99, title == "새 기도"
    func test_writePrayer_success_publishesPrayerAddedEvent() async throws {
        mockRepository.stubbedPrayerWrite = PrayerWriteResponse(
            prayerRequestId: 99,
            prayerUserId: 1,
            prayerUserName: "작성자",
            categoryId: 2,
            categoryName: "감사",
            title: "새 기도",
            content: "내용",
            createdAt: "2026-03-01",
            participationCount: 0,
            isMine: true,
            errorCode: nil,
            status: nil
        )

        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        _ = try await sut.writePrayer(categoryID: 2,
                                      title: "새 기도",
                                      content: "내용")

        if case .prayerAdded(let prayer) = receivedEvent {
            XCTAssertEqual(prayer.id, 99)
            XCTAssertEqual(prayer.title, "새 기도")
        } else {
            XCTFail("prayerAdded 이벤트가 발행되지 않았습니다")
        }
    }

    // 1. eventPublisher 구독
    // 2. sut.deletePrayer(prayerRequestId: 42) 호출
    // 3. .prayerDeleted 이벤트 발행, prayerId == 42
    // 4. mockRepository.deletePrayerCalledWith == 42
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

    // 1. mockRepository.stubbedResponseItem에 DetailResponseItem 세팅
    // 2. eventPublisher 구독
    // 3. sut.writePrayerResponse() 호출
    // 4. .responseAdded 이벤트 발행, id == 10, prayerRequestId == 1, message == "응원합니다"
    func test_writePrayerResponse_success_publishesResponseAddedEvent() async throws {
        mockRepository.stubbedResponseItem = DetailResponseItem(
            prayerResponseId: 10,
            prayerRequestId: 1,
            prayerUserId: 1,
            prayerUserName: "작성자",
            prayerRequestTitle: "기도 제목",
            message: "응원합니다",
            createdAt: "2026-03-01",
            isMine: true,
            parentResponseId: nil,
            replyCount: 0,
            errorCode: nil,
            status: nil
        )

        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        _ = try await sut.writePrayerResponse(
            prayerRequestID: 1,
            message: "응원합니다",
            prayerTitle: "기도 제목",
            categoryId: 2,
            categoryName: "감사"
        )

        if case .responseAdded(let response) = receivedEvent {
            XCTAssertEqual(response.id, 10)
            XCTAssertEqual(response.prayerRequestId, 1)
            XCTAssertEqual(response.message, "응원합니다")
        } else {
            XCTFail("responseAdded 이벤트가 발행되지 않았습니다")
        }
    }

    // 1. eventPublisher 구독
    // 2. sut.deletePrayerResponse(responseID: 5, prayerRequestId: 1) 호출
    // 3. .responseDeleted 이벤트 발행, responseId == 5, prayerRequestId == 1
    func test_deletePrayerResponse_success_publishesResponseDeletedEvent() async throws {
        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        try await sut.deletePrayerResponse(responseID: 5,
                                           prayerRequestId: 1)

        if case .responseDeleted(let responseId, let prayerRequestId) = receivedEvent {
            XCTAssertEqual(responseId, 5)
            XCTAssertEqual(prayerRequestId, 1)
        } else {
            XCTFail("responseDeleted 이벤트가 발행되지 않았습니다")
        }
    }

    // 1. mockRepository.stubbedPrayerDetail에 수정된 PrayerDetailResponse 세팅
    // 2. eventPublisher 구독
    // 3. sut.updatePrayer() 호출
    // 4. .prayerUpdated 이벤트 발행, prayer.id == 1, title == "수정된 제목"
    func test_updatePrayer_success_publishesPrayerUpdatedEvent() async throws {
        mockRepository.stubbedPrayerDetail = PrayerDetailResponse(
            prayerRequestId: 1,
            prayerUserId: 10,
            prayerUserName: "홍길동",
            categoryId: 2,
            categoryName: "감사",
            title: "수정된 제목",
            content: "수정된 내용",
            createdAt: "2026-01-01",
            participationCount: 3,
            responses: nil,
            hasParticipated: false,
            isMine: true,
            errorCode: nil,
            status: nil
        )

        var receivedEvent: PrayerEventType?
        sut.eventPublisher
            .sink { receivedEvent = $0 }
            .store(in: &cancellables)

        _ = try await sut.updatePrayer(prayerRequestId: 1,
                                       categoryID: 2,
                                        title: "수정된 제목",
                                       content: "수정된 내용")

        if case .prayerUpdated(let prayer) = receivedEvent {
            XCTAssertEqual(prayer.id, 1)
            XCTAssertEqual(prayer.title, "수정된 제목")
        } else {
            XCTFail("prayerUpdated 이벤트가 발행되지 않았습니다")
        }
    }

}
