//
//  HomeViewModelTests.swift
//  FaithConnectTests
//

import XCTest
import Combine
@testable import FaithConnect

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var sut: HomeViewModel!
    private var mockPrayerUseCase: MockPrayerUseCase!
    private let testCategories = [
        PrayerCategory(id: 1, categoryCode: 1, categoryName: "전체"),
        PrayerCategory(id: 2, categoryCode: 2, categoryName: "가족")
    ]

    private var testPrayer: Prayer {
        Prayer(id: 1,
               userId: 1,
               userName: "테스트",
               categoryId: 2,
               categoryName: "가족",
               title: "제목",
               content: "내용",
               createdAt: "2026-01-01",
               participationCount: 0,
               responses: nil,
               isMine: true)
    }

    override func setUp() {
        super.setUp()
        mockPrayerUseCase = MockPrayerUseCase()
        sut = HomeViewModel(prayerUseCase: mockPrayerUseCase)
    }

    override func tearDown() {
        sut = nil
        mockPrayerUseCase = nil
        super.tearDown()
    }

    // MARK: - Helper
    
    private func initializeWithPrayers(prayers: [Prayer], hasNext: Bool = false) async {
        mockPrayerUseCase.stubbedCategories = testCategories
        mockPrayerUseCase.stubbedPrayerPage = PrayerPage(
            prayers: prayers,
            currentPage: 1,
            hasNext: hasNext
        )
        await sut.initializeIfNeeded()
    }

    // MARK: - Initialization
    
    // 1. mockUseCase에 카테고리, 기도 데이터 세팅
    // 2. viewModel.initializeIfNeeded() 호출
    // 3. 카테고리 2개 로드, 첫 번째 카테고리 선택, 기도 1개 로드
    func test_initializeIfNeeded_loadsCategoriesAndFirstPrayers() async {
        await initializeWithPrayers(prayers: [testPrayer])

        XCTAssertTrue(mockPrayerUseCase.loadCategoriesCalled)
        XCTAssertEqual(sut.categories.count, 2)
        XCTAssertEqual(sut.selectedCategoryId, 1)
        XCTAssertEqual(sut.prayers.count, 1)
    }

    // 1. 첫 번째 initializeIfNeeded() 호출로 초기화
    // 2. loadCategoriesCalled 플래그 리셋
    // 3. 두 번째 initializeIfNeeded() 호출
    // 4. loadCategoriesCalled == false → 중복 실행 안됨
    func test_initializeIfNeeded_calledTwice_executesOnlyOnce() async {
        await initializeWithPrayers(prayers: [testPrayer])

        mockPrayerUseCase.loadCategoriesCalled = false
        await sut.initializeIfNeeded()

        XCTAssertFalse(mockPrayerUseCase.loadCategoriesCalled)
    }

    // 1. mockUseCase.stubbedError 값 할당
    // 2. viewModel.initializeIfNeeded() 호출
    // 3. stubbedError != nil → throws error
    // 4. viewModel.alertType == .error("에러", "네트워크 오류")
    func test_initializeIfNeeded_failure_showsErrorAlert() async {
        mockPrayerUseCase.stubbedError = NSError(domain: "", code: 0,
                                                 userInfo: [NSLocalizedDescriptionKey: "네트워크 오류"])

        await sut.initializeIfNeeded()

        if case .error(let title, let message) = sut.alertType {
            XCTAssertEqual(title, "에러")
            XCTAssertEqual(message, "네트워크 오류")
        } else {
            XCTFail("alertType이 .error가 아닙니다")
        }
    }

    // MARK: - Event Handling
    
    // 1. 빈 기도 목록으로 초기화
    // 2. eventPublisher로 .prayerAdded 이벤트 발행
    // 3. prayers 목록에 새 기도가 추가됨
    func test_prayerAddedEvent_insertsPrayerToList() async {
        await initializeWithPrayers(prayers: [])

        let newPrayer = Prayer(id: 99,
                               userId: 1,
                               userName: "작성자",
                               categoryId: 1,
                               categoryName: "전체",
                               title: "새 기도",
                               content: "내용",
                               createdAt: "2026-03-01",
                               participationCount: 0,
                               responses: nil,
                               isMine: true)
        
        mockPrayerUseCase.eventPublisher.send(.prayerAdded(prayer: newPrayer))

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.prayers.count, 1)
        XCTAssertEqual(sut.prayers.first?.id, 99)
    }

    // 1. 기도 1개로 초기화
    // 2. eventPublisher로 .prayerDeleted 이벤트 발행
    // 3. prayers 목록에서 해당 기도가 제거됨
    func test_prayerDeletedEvent_removesPrayerFromList() async {
        await initializeWithPrayers(prayers: [testPrayer])
        XCTAssertEqual(sut.prayers.count, 1)

        mockPrayerUseCase.eventPublisher.send(.prayerDeleted(prayerId: 1))

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.prayers.count, 0)
    }

    // 1. 기도 2개(id=1, id=2)로 초기화, participationCount 모두 0
    // 2. eventPublisher로 .responseAdded 이벤트 발행 (prayerRequestId: 1)
    // 3. id=1 기도만 participationCount 0 → 1 증가, id=2는 그대로 0
    func test_responseAddedEvent_incrementsOnlyMatchingPrayer() async {
        let prayer2 = Prayer(id: 2,
                             userId: 1,
                             userName: "테스트",
                             categoryId: 2,
                             categoryName: "가족",
                             title: "제목2",
                             content: "내용2",
                             createdAt: "2026-01-02",
                             participationCount: 0,
                             responses: nil,
                             isMine: false)
        await initializeWithPrayers(prayers: [testPrayer, prayer2])
        XCTAssertEqual(sut.prayers[0].participationCount, 0)
        XCTAssertEqual(sut.prayers[1].participationCount, 0)

        let myResponse = MyResponse(id: 1,
                                    prayerRequestId: 1,
                                    prayerRequestTitle: "제목",
                                    categoryId: 2,
                                    categoryName: "감사",
                                    message: "응답",
                                    createdAt: "2026-03-01")
        mockPrayerUseCase.eventPublisher.send(.responseAdded(response: myResponse))

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.prayers[0].participationCount, 1)  // id=1: 0 → 1 추가
        XCTAssertEqual(sut.prayers[1].participationCount, 0)  // id=2: 그대로 0
    }

    // 1. 기도 2개(id=1: count=3, id=2: count=5)로 초기화
    // 2. eventPublisher로 .responseDeleted 이벤트 발행 (prayerRequestId: 1)
    // 3. id=1 기도만 participationCount 3 → 2 감소, id=2는 그대로 5
    func test_responseDeletedEvent_decrementsOnlyMatchingPrayer() async {
        var prayer1 = testPrayer
        prayer1.participationCount = 3
        
        let prayer2 = Prayer(id: 2,
                             userId: 1,
                             userName: "테스트",
                             categoryId: 2,
                             categoryName: "가족",
                             title: "제목2",
                             content: "내용2",
                             createdAt: "2026-01-02",
                             participationCount: 5,
                             responses: nil,
                             isMine: false)
        
        await initializeWithPrayers(prayers: [prayer1, prayer2])

        mockPrayerUseCase.eventPublisher.send(.responseDeleted(responseId: 10,
                                                               prayerRequestId: 1))

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.prayers[0].participationCount, 2)  // id=1: 3 → 2 감소
        XCTAssertEqual(sut.prayers[1].participationCount, 5)  // id=2: 그대로 5
    }

    // MARK: - Pagination
    
    // 1. 기도 1개, hasNext=true로 초기화
    // 2. 2페이지 응답 데이터 세팅
    // 3. viewModel.loadMorePrayers() 호출
    // 4. prayers.count == 2 (기존 1개 + 새로 1개 append)
    // 5. 요청한 page == 2
    func test_loadMorePrayers_appendsToExistingList() async {
        await initializeWithPrayers(prayers: [testPrayer], hasNext: true)

        let prayer2 = Prayer(id: 2,
                             userId: 1,
                             userName: "테스트",
                             categoryId: 2,
                             categoryName: "감사",
                             title: "제목2",
                             content: "내용2",
                             createdAt: "2026-01-02",
                             participationCount: 0,
                             responses: nil,
                             isMine: false)
        
        mockPrayerUseCase.stubbedPrayerPage = PrayerPage(
            prayers: [prayer2],
            currentPage: 2,
            hasNext: false
        )

        await sut.loadMorePrayers()

        XCTAssertEqual(sut.prayers.count, 2)
        XCTAssertEqual(mockPrayerUseCase.loadPrayersCalledWith?.page, 2)
    }

    // 1. 기도 1개, hasNext=false(기본값)로 초기화
    // 2. loadPrayersCalledWith 리셋
    // 3. viewModel.loadMorePrayers() 호출
    // 4. loadPrayersCalledWith == nil → 추가 요청 안함
    func test_loadMorePrayers_hasNextFalse_doesNotLoad() async {
        await initializeWithPrayers(prayers: [testPrayer])

        mockPrayerUseCase.loadPrayersCalledWith = nil
        await sut.loadMorePrayers()

        XCTAssertNil(mockPrayerUseCase.loadPrayersCalledWith)
    }

    // 1. mockUseCase.stubbedError 값 할당
    // 2. viewModel.loadMorePrayers() 호출
    // 3. stubbedError != nil → throws error
    // 4. viewModel.alertType == .error("에러", "서버 오류")
    func test_loadMorePrayers_failure_showsErrorAlert() async {
        await initializeWithPrayers(prayers: [testPrayer], hasNext: true)

        mockPrayerUseCase.stubbedError = NSError(domain: "", code: 0,
                                                 userInfo: [NSLocalizedDescriptionKey: "서버 오류"])
        await sut.loadMorePrayers()

        if case .error(let title, let message) = sut.alertType {
            XCTAssertEqual(title, "에러")
            XCTAssertEqual(message, "서버 오류")
        } else {
            XCTFail("alertType이 .error가 아닙니다")
        }
    }

    // MARK: - Category Selection
    
    // 1. 기본 카테고리(id=1)로 초기화
    // 2. 빈 기도 페이지 세팅
    // 3. viewModel.selectCategory(categoryID: 2) 호출
    // 4. selectedCategoryId == 2, 요청한 categoryID == 2
    func test_selectCategory_differentCategory_reloadsPrayers() async {
        await initializeWithPrayers(prayers: [testPrayer])

        mockPrayerUseCase.stubbedPrayerPage = PrayerPage(
            prayers: [],
            currentPage: 1,
            hasNext: false
        )
        
        await sut.selectCategory(categoryID: 2)

        XCTAssertEqual(sut.selectedCategoryId, 2)
        XCTAssertEqual(mockPrayerUseCase.loadPrayersCalledWith?.categoryID, 2)
    }

    // 1. mockUseCase.stubbedError 값 할당
    // 2. viewModel.selectCategory(categoryID: 2) 호출
    // 3. stubbedError != nil → throws error
    // 4. viewModel.alertType == .error("에러", "서버 오류")
    func test_selectCategory_failure_showsErrorAlert() async {
        await initializeWithPrayers(prayers: [testPrayer])

        mockPrayerUseCase.stubbedError = NSError(domain: "", code: 0,
                                                 userInfo: [NSLocalizedDescriptionKey: "서버 오류"])
        await sut.selectCategory(categoryID: 2)

        if case .error(let title, let message) = sut.alertType {
            XCTAssertEqual(title, "에러")
            XCTAssertEqual(message, "서버 오류")
        } else {
            XCTFail("alertType이 .error가 아닙니다")
        }
    }
}
