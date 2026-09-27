//
//  PrayerRepositoryTests.swift
//  FaithConnectTests
//

import XCTest
@testable import FaithConnect

final class PrayerRepositoryTests: XCTestCase {

    private var sut: PrayerRepository!
    private var mockAPIClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        sut = PrayerRepository(apiClient: mockAPIClient)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        super.tearDown()
    }

    // MARK: - DTO → Entity 변환

    func test_loadCategories_mapsDTOToEntity() async throws {
        mockAPIClient.stubbedCategories = [
            CategoryResponse(categoryId: 1, categoryCode: 1, categoryName: "전체"),
            CategoryResponse(categoryId: 2, categoryCode: 2, categoryName: "가족")
        ]

        let result = try await sut.loadCategories()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].categoryName, "전체")
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[1].categoryName, "가족")
    }

    func test_loadPrayers_mapsDTOToPrayerPage() async throws {
        let dto = PrayerDetailResponse(
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
            errorCode: nil
        )

        mockAPIClient.stubbedPrayerList = PrayerListResponse(
            prayerRequests: [dto],
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

    func test_loadPrayerDetail_mapsDTOToPrayer() async throws {
        mockAPIClient.stubbedPrayerDetail = PrayerDetailResponse(
            prayerRequestId: 1,
            prayerUserId: 10,
            prayerUserName: "홍길동",
            categoryId: 2,
            categoryName: "가족",
            title: "기도 제목",
            content: "기도 내용",
            createdAt: "2026-01-01",
            participationCount: 3,
            responses: nil,
            hasParticipated: true,
            isMine: false,
            errorCode: nil
        )

        let result = try await sut.loadPrayerDetail(prayerRequestID: 1)

        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.userId, 10)
        XCTAssertEqual(result.userName, "홍길동")
        XCTAssertEqual(result.categoryId, 2)
        XCTAssertEqual(result.title, "기도 제목")
        XCTAssertEqual(result.content, "기도 내용")
        XCTAssertEqual(result.participationCount, 3)
        XCTAssertTrue(result.hasParticipated)
        XCTAssertFalse(result.isMine)
    }

    func test_writePrayer_mapsDTOToPrayer() async throws {
        mockAPIClient.stubbedPrayerWrite = PrayerWriteResponse(
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

        let result = try await sut.writePrayer(categoryID: 2, title: "새 기도", content: "내용")

        XCTAssertEqual(result.id, 99)
        XCTAssertEqual(result.userName, "작성자")
        XCTAssertEqual(result.title, "새 기도")
        XCTAssertTrue(result.isMine)
    }

    func test_writePrayerResponse_mapsDTOToEntity() async throws {
        mockAPIClient.stubbedResponseItem = DetailResponseItem(
            prayerResponseId: 10,
            prayerRequestId: 1,
            prayerUserId: 5,
            prayerUserName: "응답자",
            prayerRequestTitle: "기도 제목",
            message: "응원합니다",
            createdAt: "2026-03-01",
            isMine: true,
            parentResponseId: nil,
            replyCount: 0,
            errorCode: nil,
            status: nil
        )

        let result = try await sut.writePrayerResponse(prayerRequestID: 1, message: "응원합니다")

        XCTAssertEqual(result.id, 10)
        XCTAssertEqual(result.prayerRequestId, 1)
        XCTAssertEqual(result.userName, "응답자")
        XCTAssertEqual(result.message, "응원합니다")
        XCTAssertTrue(result.isMine)
    }

    func test_loadParticipatedPrayers_mapsDTOToEntity() async throws {
        mockAPIClient.stubbedMyResponseList = MyResponseList(
            responses: [
                MyResponseItem(
                    prayerResponseId: 1,
                    prayerRequestId: 10,
                    prayerRequestTitle: "기도 제목",
                    categoryId: 2,
                    categoryName: "가족",
                    message: "응답 메시지",
                    createdAt: "2026-03-01"
                )
            ],
            currentPage: 1,
            totalElements: 1,
            pageSize: 10,
            hasNext: false,
            hasPrevious: false
        )

        let result = try await sut.loadParticipatedPrayers(page: 1)

        XCTAssertEqual(result.responses.count, 1)
        XCTAssertEqual(result.responses[0].id, 1)
        XCTAssertEqual(result.responses[0].prayerRequestTitle, "기도 제목")
        XCTAssertEqual(result.responses[0].message, "응답 메시지")
        XCTAssertEqual(result.currentPage, 1)
        XCTAssertFalse(result.hasNext)
    }

    func test_loadBlockList_mapsDTOToEntity() async throws {
        mockAPIClient.stubbedBlockList = BlockListResponse(
            blocks: [
                BlockItem(blockId: 1, blockedUserId: 100, blockedUserName: "차단유저", createdAt: "2026-03-01")
            ],
            currentPage: 1,
            totalPages: 2,
            totalElements: 15
        )

        let result = try await sut.loadBlockList(page: 1)

        XCTAssertEqual(result.blockedUsers.count, 1)
        XCTAssertEqual(result.blockedUsers[0].id, 1)
        XCTAssertEqual(result.blockedUsers[0].userId, 100)
        XCTAssertEqual(result.blockedUsers[0].userName, "차단유저")
        XCTAssertEqual(result.currentPage, 1)
        XCTAssertTrue(result.hasNext)
    }

    func test_loadReplies_mapsDTOToEntity() async throws {
        mockAPIClient.stubbedReplyList = ReplyListResponse(
            replies: [
                DetailResponseItem(
                    prayerResponseId: 20,
                    prayerRequestId: 1,
                    prayerUserId: 5,
                    prayerUserName: "답글 작성자",
                    prayerRequestTitle: nil,
                    message: "답글 내용",
                    createdAt: "2026-03-01",
                    isMine: false,
                    parentResponseId: 10,
                    replyCount: 0,
                    errorCode: nil,
                    status: nil
                )
            ],
            currentPage: 1,
            totalPages: 1,
            totalElements: 1
        )

        let result = try await sut.loadReplies(responseId: 10, page: 1)

        XCTAssertEqual(result.replies.count, 1)
        XCTAssertEqual(result.replies[0].id, 20)
        XCTAssertEqual(result.replies[0].userName, "답글 작성자")
        XCTAssertEqual(result.replies[0].parentResponseId, 10)
        XCTAssertEqual(result.currentPage, 1)
        XCTAssertFalse(result.hasNext)
    }

    // MARK: - 에러 변환 (APIError → DomainError)

    func test_loadPrayerDetail_prayerNotFound_throwsDomainError() async {
        mockAPIClient.stubbedError = APIError.serverMessage(code: .prayerNotFound)

        do {
            _ = try await sut.loadPrayerDetail(prayerRequestID: 999)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertTrue(error is DomainError)
            if case DomainError.prayerNotFound = error {} else {
                XCTFail("DomainError.prayerNotFound여야 합니다, 실제: \(error)")
            }
        }
    }

    func test_reportPrayer_alreadyReported_throwsDomainError() async {
        mockAPIClient.stubbedError = APIError.serverMessage(code: .invalidRequestParameter)

        do {
            try await sut.reportPrayer(prayerRequestId: 1, reasonType: .spam, reasonDetail: nil)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertTrue(error is DomainError)
            if case DomainError.alreadyReported = error {} else {
                XCTFail("DomainError.alreadyReported여야 합니다, 실제: \(error)")
            }
        }
    }

    func test_reportPrayerResponse_alreadyReported_throwsDomainError() async {
        mockAPIClient.stubbedError = APIError.serverMessage(code: .invalidRequestParameter)

        do {
            try await sut.reportPrayerResponse(prayerResponseId: 1, reasonType: .spam, reasonDetail: nil)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertTrue(error is DomainError)
            if case DomainError.alreadyReported = error {} else {
                XCTFail("DomainError.alreadyReported여야 합니다, 실제: \(error)")
            }
        }
    }

    func test_blockUser_alreadyBlocked_throwsDomainError() async {
        mockAPIClient.stubbedError = APIError.serverMessage(code: .invalidRequestParameter)

        do {
            try await sut.blockUser(userId: 100)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertTrue(error is DomainError)
            if case DomainError.alreadyBlocked = error {} else {
                XCTFail("DomainError.alreadyBlocked여야 합니다, 실제: \(error)")
            }
        }
    }

    func test_loadPrayerDetail_otherError_propagatesOriginalError() async {
        mockAPIClient.stubbedError = APIError.noNetwork

        do {
            _ = try await sut.loadPrayerDetail(prayerRequestID: 1)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertFalse(error is DomainError)
            XCTAssertTrue(error is APIError)
        }
    }
}
