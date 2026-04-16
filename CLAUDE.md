# CLAUDE.md

이 파일은 이 저장소에서 코드 작업할 때 Claude Code를 돕기 위한 가이드를 제공합니다.

## 프로젝트 개요

FaithConnect는 기도 요청을 공유하고 응답하는 iOS 앱(SwiftUI)입니다. 코드베이스는 **클린 아키텍처**를 따르며 Data, Domain, Presentation 계층이 명확하게 분리되어 있습니다. 앱은 **async/await**를 사용한 비동기 작업과 **Combine**을 사용한 반응형 패턴을 사용합니다.

## 빌드 및 실행

**앱 빌드:**
```bash
xcodebuild build -project FaithConnect.xcodeproj -scheme FaithConnect -configuration Debug
```

**시뮬레이터에서 앱 실행:**
```bash
xcodebuild test -project FaithConnect.xcodeproj -scheme FaithConnect -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Xcode에서 열기:**
```bash
open FaithConnect.xcodeproj
```

## 아키텍처

### 디렉토리 구조

프로젝트는 **클린 아키텍처**를 따르며 세 가지 주요 계층으로 구성됩니다:

```
FaithConnect/
├── App/                          # 앱 진입점 & 루트 로직
│   ├── FaithConnectApp.swift     # 앱 초기화, 의존성 주입
│   ├── SplashView.swift          # 스플래시/시작 화면
│   └── RootView                  # 인증 상태 관리 & 네비게이션
│
├── Presentation/                 # UI 계층 (SwiftUI Views & ViewModels)
│   ├── Views/                    # 모든 SwiftUI View 파일
│   │   ├── Components/           # 재사용 가능한 UI 컴포넌트 (버튼, 카드 등)
│   │   ├── Home/                 # 홈 탭 뷰
│   │   ├── Login/                # 인증 뷰
│   │   ├── MainTab/              # 메인 탭 컨테이너
│   │   ├── MyPage/               # 사용자 프로필/설정
│   │   ├── MyPrayer/             # 사용자의 기도 & 응답
│   │   └── Prayer/               # 기도 상세 & 편집기 뷰
│   │
│   ├── ViewModels/               # ObservableObject 상태 관리자 (@MainActor)
│   │   ├── Home/
│   │   ├── Login/
│   │   ├── MyPage/
│   │   ├── MyPrayer/
│   │   └── Prayer/
│   │
│   └── Utils/                    # UI 계층용 헬퍼
│       ├── Extensions/           # SwiftUI & Foundation 확장
│       └── Alert/                # 알림/다이얼로그 관리
│
├── Domain/                       # 비즈니스 로직 계층 (Entities & Use Cases)
│   ├── Entities/                 # 핵심 도메인 모델 (Prayer, User, Category 등)
│   ├── UseCases/                 # 고수준 작업 (PrayerUseCase)
│   └── Interfaces/               # 저장소 & Use Case 프로토콜
│
└── Data/                         # 데이터 접근 계층 (Repositories & Network)
    ├── Repositories/             # 저장소 패턴 구현
    ├── Network/
    │   ├── APIClient.swift       # HTTP 클라이언트 & 요청 처리
    │   ├── APIEndPoint.swift     # API 엔드포인트 정의
    │   ├── APIError.swift        # 에러 타입
    │   ├── AuthRequirement.swift # 인증 요구사항 열거형
    │   └── DTOs/                 # 데이터 전송 객체 (요청/응답 모델)
    └── Storage/                  # 로컬 데이터 저장
        ├── UserSession.swift     # 메모리 내 사용자 세션 상태
        └── TokenStorage.swift    # 보안 토큰 관리 (Keychain)
```

### 데이터 흐름

1. **Views** (Presentation) → ViewModel의 메서드 호출
2. **ViewModels** → **UseCases** (Domain)에 위임
3. **UseCases** → **Repositories** (Data 계층)에 위임
4. **Repositories** → 네트워크 요청을 위해 **APIClient** 호출
5. **APIClient** → 인증 헤더를 위해 **TokenStorage** 사용
6. **Domain Entities** 네트워크 **DTOs**를 비즈니스 모델로 변환

**예제 흐름:**
```
HomeView → HomeViewModel.loadPrayers()
         → PrayerUseCase.loadPrayers()
         → PrayerRepository.loadPrayers()
         → APIClient.loadPrayers()
         → URLSession
```

### 주요 패턴

**의존성 주입:** 앱은 `FaithConnectApp.init()`에서 의존성을 초기화합니다:
- APIClient는 TokenStorage로 생성됨
- PrayerRepository는 APIClient로 생성됨
- PrayerUseCase는 PrayerRepository로 생성됨
- ViewModels는 주입된 Use Case를 받음

**프로토콜:** 모든 주요 컴포넌트는 느슨한 결합을 위해 프로토콜을 사용합니다:
- `APIClientProtocol` (APIClient.swift에서 정의)
- `PrayerRepositoryProtocol` (Data/Repositories/에 있음)
- `PrayerUseCaseProtocol` (Domain/UseCases/에 있음)
- `TokenStorageProtocol` (Data/Storage/에 있음)

**ViewModels:** 모든 ViewModel은 `@MainActor`로 표시되어 UI 업데이트가 메인 스레드에서 실행되도록 합니다:
- `ObservableObject`를 상속받음
- 반응형 상태를 위해 `@Published` 프로퍼티 사용
- Combine의 `sink`와 `store(in:)`를 사용하여 이벤트 바인딩

**이벤트 기반 업데이트:** PrayerUseCase는 `eventPublisher: PassthroughSubject<PrayerEventType, Never>`를 통해 이벤트를 발행하여 기도가 추가/업데이트/삭제될 때 UI에 알립니다. 이를 통해 다시 조회하지 않아도 실시간 UI 업데이트가 가능합니다.

## 중요한 TODO & 알려진 문제점

다음 파일들에 미완료 작업이 표시되어 있습니다 (`// TODO:` 마크):

1. **FaithConnectApp.swift** (32줄, 42줄, 60줄):
   - AuthUseCase 필요 (현재 인증을 위해 APIClient를 직접 사용 중)
   - AuthRepository를 생성하여 인증 작업 추상화
   - ViewModel이 APIClient를 직접 참조하지 않아야 함

2. **MyPrayerViewModel.swift**:
   - `loadWrittenPrayers`, `loadParticipatedPrayers`, `deletePrayer` 메서드는 스텁 상태 (주석 처리됨)
   - PrayerUseCase를 사용한 구현 필요

3. **HomeViewModel.swift** (64줄):
   - 카테고리/기도 로딩 시 에러 처리 최소화됨

## 테스트 작성 고려사항

- 프로젝트에 테스트 파일이 없음
- ViewModel을 위한 단위 테스트 추가 고려 (상태 관리 및 비즈니스 로직 테스트)
- APIClient와 Repositories를 위한 통합 테스트 추가 고려

## Xcode 프로젝트 설정

- **Product Name:** FaithConnect
- **Bundle Identifier:** hansol.FaithConnect
- **Swift Version:** 5.0
- **Target Devices:** iPhone & iPad (1, 2)
- **최소 배포:** iOS 14+

## 코드 스타일

- **언어:** Swift
- **주석 & 커밋 메시지:** 한국어
- **변수/함수명:** 영어 (Swift 명명 규칙 준수)
- **MARK 주석:** 코드 섹션 정렬에 광범위하게 사용됨
- **접근 제어:** 구현 세부사항은 `private`, 계층 내부 API는 `internal` 사용

## 일반적인 개발 워크플로우

**기도 작업에 새 기능 추가:**

1. `APIClient`에 API 엔드포인트 메서드 추가 (프로토콜 준수)
2. `PrayerRepository`에 APIClient로 위임하는 저장소 메서드 추가
3. DTOs를 도메인 엔티티로 변환하는 `PrayerUseCase` 메서드 추가
4. 업데이트 발행을 위한 `PrayerEventType` 케이스 정의 (선택사항)
5. Use Case를 호출하는 ViewModel 메서드 추가
6. ViewModel 메서드를 View 액션에 연결

**인증 흐름 수정:**

- 현재 인증은 분산됨: APIClient의 Login/SignUp, UserSession의 세션
- TODO: AuthUseCase와 AuthRepository를 생성하여 통합
- FaithConnectApp의 앱 진입점을 업데이트하여 APIClient 대신 AuthUseCase 주입

**사용자 데이터 접근:**

- 현재 사용자는 `UserSession`에 저장됨 (FaithConnectApp의 @StateObject)
- 토큰은 `TokenStorage`에 저장됨 (Keychain 백엔드 사용)
- 사용자 컨텍스트가 필요한 View/ViewModel에 `UserSession` 전달
- APIClient는 `AuthRequirement` 열거형을 통해 자동으로 요청에 토큰 추가
