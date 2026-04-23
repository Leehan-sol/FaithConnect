//
//  LoginViewModelTests.swift
//  FaithConnectTests
//

import XCTest
@testable import FaithConnect

@MainActor
final class LoginViewModelTests: XCTestCase {

    private var sut: LoginViewModel!
    private var mockAuthUseCase: MockAuthUseCase!
    private var session: UserSession!

    override func setUp() {
        super.setUp()
        mockAuthUseCase = MockAuthUseCase()
        session = UserSession()
        sut = LoginViewModel(authUseCase: mockAuthUseCase, session: session)
    }

    override func tearDown() {
        sut = nil
        mockAuthUseCase = nil
        session = nil
        super.tearDown()
    }

    // MARK: - Email Validation

    // 1. 유효한 이메일 형식 입력
    // 2. isValidEmail() == true
    func test_isValidEmail_validFormat_returnsTrue() {
        XCTAssertTrue(sut.isValidEmail(email: "user@example.com"))
        XCTAssertTrue(sut.isValidEmail(email: "test.user@domain.co.kr"))
    }

    // 1. 유효하지 않은 이메일 형식 입력 (빈값, @없음, 도메인없음 등)
    // 2. isValidEmail() == false
    func test_isValidEmail_invalidFormat_returnsFalse() {
        XCTAssertFalse(sut.isValidEmail(email: ""))
        XCTAssertFalse(sut.isValidEmail(email: "invalid"))
        XCTAssertFalse(sut.isValidEmail(email: "user@"))
        XCTAssertFalse(sut.isValidEmail(email: "@domain.com"))
    }

    // MARK: - Password Validation

    // 1. 유효한 비밀번호 입력 (영문+숫자, 8자 이상)
    // 2. isValidPassword() == true
    func test_isValidPassword_validFormat_returnsTrue() {
        XCTAssertTrue(sut.isValidPassword(password: "password1"))
        XCTAssertTrue(sut.isValidPassword(password: "Abcdef12"))
    }

    // 1. 유효하지 않은 비밀번호 입력 (빈값, 숫자없음, 영문없음, 8자 미만)
    // 2. isValidPassword() == false
    func test_isValidPassword_invalidFormat_returnsFalse() {
        XCTAssertFalse(sut.isValidPassword(password: ""))
        XCTAssertFalse(sut.isValidPassword(password: "abcdefgh"))   // 숫자 없음
        XCTAssertFalse(sut.isValidPassword(password: "12345678"))   // 영문 없음
        XCTAssertFalse(sut.isValidPassword(password: "abc1"))       // 8자 미만
    }

    // MARK: - Login

    // 1. 빈 이메일로 login() 호출
    // 2. alertType == .fieldEmpty(fieldName: "이메일")
    // 3. mockUseCase.login 호출 안됨
    func test_login_emptyEmail_showsFieldEmptyAlert() async {
        await sut.login(email: "", password: "password1")

        XCTAssertEqual(sut.alertType, .fieldEmpty(fieldName: "이메일"))
        XCTAssertNil(mockAuthUseCase.loginCalledWith)
    }

    // 1. 빈 비밀번호로 login() 호출
    // 2. alertType == .fieldEmpty(fieldName: "비밀번호")
    // 3. mockUseCase.login 호출 안됨
    func test_login_emptyPassword_showsFieldEmptyAlert() async {
        await sut.login(email: "test@test.com", password: "")

        XCTAssertEqual(sut.alertType, .fieldEmpty(fieldName: "비밀번호"))
        XCTAssertNil(mockAuthUseCase.loginCalledWith)
    }

    // 1. mockUseCase.stubbedUser 값 할당
    // 2. mockUseCase.login
    // 3. fetchMyInfo - stubbedUser 값 return
    // 4. session.isLoggedIn, session.name fetchMyInfo에서 return한 이름
    func test_login_success_setsSessionLoggedIn() async {
        mockAuthUseCase.stubbedUser = User(name: "홍길동", nickname: "길동이", email: "hong@test.com")

        await sut.login(email: "hong@test.com", password: "password1")

        XCTAssertTrue(session.isLoggedIn)
        XCTAssertEqual(session.name, "홍길동")
        XCTAssertEqual(mockAuthUseCase.loginCalledWith?.email, "hong@test.com")
        XCTAssertTrue(mockAuthUseCase.fetchMyInfoCalled)
    }

    // 1. mockUseCase.stubbedError 값 할당
    // 2. mockUseCase.login
    // 3. stubbedError != nil throws error
    // 4. viewModel.alertType .error
    // 5. session.isLoggedIn false
    func test_login_failure_showsErrorAlert() async {
        mockAuthUseCase.stubbedError = NSError(domain: "", code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "인증 실패"])

        await sut.login(email: "test@test.com", password: "wrong")

        XCTAssertFalse(session.isLoggedIn)
        XCTAssertNotNil(sut.alertType)
        if case .error(let title, _) = sut.alertType {
            XCTAssertEqual(title, "로그인 실패")
        } else {
            XCTFail("alertType이 .error가 아닙니다")
        }
    }

    // 1. mockUseCase.login
    // 2. defer { isLoading = false }
    // 3. viewModel.isLoading false
    func test_login_completion_setsIsLoadingFalse() async {
        await sut.login(email: "test@test.com", password: "password1")

        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Sign Up

    // 1. 빈 이름으로 signUp() 호출
    // 2. signUpAlertType == .fieldEmpty(fieldName: "이름")
    func test_signUp_emptyName_showsFieldEmptyAlert() async {
        await sut.signUp(name: "", nickname: "닉네임", email: "e@e.com",
                         password: "password1", confirmPassword: "password1")

        XCTAssertEqual(sut.signUpAlertType, .fieldEmpty(fieldName: "이름"))
    }

    // 1. 빈 닉네임으로 signUp() 호출
    // 2. signUpAlertType == .fieldEmpty(fieldName: "닉네임")
    func test_signUp_emptyNickname_showsFieldEmptyAlert() async {
        await sut.signUp(name: "이름", nickname: "", email: "e@e.com",
                         password: "password1", confirmPassword: "password1")

        XCTAssertEqual(sut.signUpAlertType, .fieldEmpty(fieldName: "닉네임"))
    }

    // 1. 비밀번호 != 비밀번호 확인으로 signUp() 호출
    // 2. signUpAlertType == .error("비밀번호 오류", ...)
    func test_signUp_passwordMismatch_showsErrorAlert() async {
        await sut.signUp(name: "이름", nickname: "닉네임", email: "e@e.com",
                         password: "password1", confirmPassword: "different1")

        if case .error(let title, _) = sut.signUpAlertType {
            XCTAssertEqual(title, "비밀번호 오류")
        } else {
            XCTFail("signUpAlertType이 .error가 아닙니다")
        }
    }

    // 1. 유효하지 않은 이메일로 signUp() 호출
    // 2. signUpAlertType == .error("이메일 형식 오류", ...)
    func test_signUp_invalidEmail_showsErrorAlert() async {
        await sut.signUp(name: "이름", nickname: "닉네임", email: "invalid",
                         password: "password1", confirmPassword: "password1")

        if case .error(let title, _) = sut.signUpAlertType {
            XCTAssertEqual(title, "이메일 형식 오류")
        } else {
            XCTFail("signUpAlertType이 .error가 아닙니다")
        }
    }

    // 1. 유효하지 않은 비밀번호로 signUp() 호출
    // 2. signUpAlertType == .error("비밀번호 형식 오류", ...)
    func test_signUp_invalidPassword_showsErrorAlert() async {
        await sut.signUp(name: "이름", nickname: "닉네임", email: "e@e.com",
                         password: "short", confirmPassword: "short")

        if case .error(let title, _) = sut.signUpAlertType {
            XCTAssertEqual(title, "비밀번호 형식 오류")
        } else {
            XCTFail("signUpAlertType이 .error가 아닙니다")
        }
    }

    // 1. mockUseCase.signUp
    // 2. signUpCalledWith
    // 3. viewModel.alertType .registerSuccess
    func test_signUp_success_showsRegisterSuccessAlert() async {
        await sut.signUp(name: "이름",
                         nickname: "닉네임",
                         email: "e@e.com",
                         password: "password1",
                         confirmPassword: "password1")

        XCTAssertNotNil(mockAuthUseCase.signUpCalledWith)
        XCTAssertEqual(sut.signUpAlertType, .registerSuccess)
    }

    // 1. mockUseCase.stubbedError 값 할당
    // 2. mockUseCase.signUp
    // 3. stubbedError != nil throws error
    // 4. viewModel.alertType .error
    func test_signUp_failure_showsErrorAlert() async {
        mockAuthUseCase.stubbedError = NSError(domain: "", code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "이미 가입된 이메일"])

        await sut.signUp(name: "이름",
                         nickname: "닉네임",
                         email: "e@e.com",
                         password: "password1",
                         confirmPassword: "password1")

        if case .error(let title, _) = sut.signUpAlertType {
            XCTAssertEqual(title, "회원가입 실패")
        } else {
            XCTFail("signUpAlertType이 .error가 아닙니다")
        }
    }

    // MARK: - Find ID

    // 1. 빈 이름으로 findID() 호출
    // 2. result == nil
    // 3. findIDAlertType == .fieldEmpty(fieldName: "이름")
    func test_findID_emptyName_returnsNil() async {
        let result = await sut.findID(name: "", nickname: "닉네임")

        XCTAssertNil(result)
        XCTAssertEqual(sut.findIDAlertType, .fieldEmpty(fieldName: "이름"))
    }

    // 1. 빈 닉네임으로 findID() 호출
    // 2. result == nil
    // 3. findIDAlertType == .fieldEmpty(fieldName: "닉네임")
    func test_findID_emptyNickname_returnsNil() async {
        let result = await sut.findID(name: "이름", nickname: "")

        XCTAssertNil(result)
        XCTAssertEqual(sut.findIDAlertType, .fieldEmpty(fieldName: "닉네임"))
    }

    // 1. mockUseCase.stubbedFoundEmail 값 할당
    // 2. mockUseCase.findId
    // 3. mockUseCase.findIDCalledWith
    // 4. mockUseCase.stubbedFoundEmail 값 return
    func test_findID_success_returnsEmail() async {
        mockAuthUseCase.stubbedFoundEmail = "found@test.com"

        let result = await sut.findID(name: "홍길동", nickname: "길동이")

        XCTAssertEqual(mockAuthUseCase.findIDCalledWith?.name, "홍길동")
        XCTAssertEqual(mockAuthUseCase.findIDCalledWith?.nickname, "길동이")
        XCTAssertEqual(result, "found@test.com")
    }

    // 1. mockUseCase.stubbedError 값 할당
    // 2. mockUseCase.findId
    // 3. stubbedError != nil throws error
    // 4. viewModel.alertType .error
    func test_findID_failure_showsErrorAlert() async {
        mockAuthUseCase.stubbedError = NSError(domain: "", code: 0)

        let result = await sut.findID(name: "홍길동", nickname: "길동이")

        XCTAssertNil(result)
        if case .error(let title, _) = sut.findIDAlertType {
            XCTAssertEqual(title, "아이디 찾기 실패")
        } else {
            XCTFail("findIDAlertType이 .error가 아닙니다")
        }
    }
}
