# FaithConnect 🙏

익명으로 기도 요청을 공유하고, 다른 사람들의 기도에 응답하는 신앙 커뮤니티 앱입니다.
**무작위로 받는 푸시 알림을 통해 누군가의 기도를 발견하고 응답할 수 있습니다.**

## 📱 앱 개요

FaithConnect는 개인의 신앙을 나누고 서로를 지지하는 익명 기반의 기도 공유 플랫폼입니다.

### 핵심 기능
- **익명 기도 요청**: 신원을 드러내지 않고 기도 요청을 등록
- **카테고리 기반 분류**: 건강, 가족, 일, 관계 등 다양한 주제로 구분
- **익명 응답**: 다른 사람의 기도 요청에 익명으로 응답 및 격려
- **푸시 알림**: 무작위로 다른 사람의 기도 요청을 받고 응답할 수 있음
- **나의 기도 관리**: 올린 기도와 받은 응답 확인
- **프로필 관리**: 계정 설정 및 기본 정보 관리

---

## 🏗️ 아키텍처

FaithConnect는 **Clean Architecture**를 따릅니다. 세 가지 명확한 계층으로 분리되어 있어 코드의 유지보수성과 테스트 가능성을 높입니다.

```
📁 FaithConnect/
├── 🔷 App/                          # 앱 진입점 & 의존성 주입
│   ├── FaithConnectApp.swift        # 앱 초기화
│   ├── SplashView.swift             # 스플래시 화면
│   └── RootView                     # 인증 상태 관리 & 네비게이션
│
├── 🎨 Presentation/                 # UI 계층 (SwiftUI)
│   ├── Views/
│   │   ├── Components/              # 재사용 가능한 UI 컴포넌트
│   │   ├── Home/                    # 기도 목록 탭
│   │   ├── Login/                   # 로그인 페이지
│   │   ├── MainTab/                 # 메인 탭 네비게이션
│   │   ├── MyPage/                  # 프로필 & 설정
│   │   ├── MyPrayer/                # 내 기도 & 응답 관리
│   │   └── Prayer/                  # 기도 상세 & 작성 뷰
│   │
│   ├── ViewModels/                  # 상태 관리 (@MainActor, @Published)
│   │   ├── Home/HomeViewModel
│   │   ├── Prayer/PrayerDetailViewModel
│   │   ├── Prayer/PrayerEditorViewModel
│   │   ├── MyPrayer/MyPrayerViewModel
│   │   ├── MyPage/MyPageViewModel
│   │   └── Login/LoginViewModel
│   │
│   └── Utils/                       # UI 헬퍼 & 확장
│       ├── Extensions/
│       └── Alert/
│
├── 📚 Domain/                       # 비즈니스 로직 계층
│   ├── Entities/                    # 핵심 모델
│   │   ├── Prayer.swift             # 기도 요청
│   │   ├── PrayerResponse.swift     # 기도 응답
│   │   ├── PrayerCategory.swift     # 기도 카테고리
│   │   ├── User.swift               # 사용자
│   │   └── MyResponse.swift         # 내가 한 응답
│   │
│   ├── UseCases/                    # 비즈니스 로직
│   │   ├── PrayerUseCase.swift      # 기도 관련 작업
│   │   └── PrayerEventType.swift    # 이벤트 타입
│   │
│   └── Interfaces/                  # 프로토콜 정의
│       └── PrayerRepositoryProtocol
│
└── 💾 Data/                         # 데이터 접근 계층
    ├── Repositories/                # 저장소 패턴
    │   └── PrayerRepository.swift
    │
    ├── Network/                     # HTTP 통신
    │   ├── APIClient.swift          # HTTP 클라이언트
    │   ├── APIEndPoint.swift        # API 엔드포인트
    │   ├── APIError.swift           # 에러 타입
    │   ├── AuthRequirement.swift    # 인증 요구사항
    │   └── DTOs/                    # 데이터 전송 객체
    │       ├── PrayerDTOs.swift
    │       ├── AuthDTOs.swift
    │       └── CategoryDTOs.swift
    │
    └── Storage/                     # 로컬 저장소
        ├── UserSession.swift        # 사용자 세션 (메모리)
        └── TokenStorage.swift       # 인증 토큰 (Keychain)
```

### 데이터 흐름

```
View → ViewModel → UseCase → Repository → APIClient → Network
 ↓         ↓           ↓           ↓            ↓
Event  Published   eventPublisher  Combine   URLSession
```

예시: 기도 목록 로드
```
HomeView
  → HomeViewModel.initializeIfNeeded()
    → PrayerUseCase.loadPrayers()
      → PrayerRepository.loadPrayers()
        → APIClient.loadPrayers()
          → URLSession (API 요청)
            → HomeViewModel의 @Published prayers 업데이트
              → View 자동 새로고침
```

---

## 📖 주요 페이지 및 기능

### 1. 로그인 페이지 (`LoginView`)
사용자가 계정에 로그인하는 페이지입니다.
- 이메일/비밀번호 입력
- 회원가입 & 로그인 기능
- 세션 및 토큰 저장

### 2. 홈 탭 (`HomeView`)
기도 요청을 탐색하고 응답하는 메인 화면입니다.
- **카테고리 필터링**: 건강, 가족, 일, 관계, 기타
- **기도 목록**: 최신순으로 기도 요청 표시
- **무한 스크롤**: 스크롤 시 자동으로 더 많은 기도 로드
- **기도 상세 열기**: 기도를 탭하면 상세 페이지로 이동

**ViewModel**: `HomeViewModel`
```swift
@Published var categories: [PrayerCategory]
@Published var prayers: [Prayer]
@Published var selectedCategoryId: Int
@Published var isLoading: Bool
@Published var isRefreshing: Bool
```

### 3. 기도 상세 페이지 (`PrayerDetailView`)
기도 요청의 상세 내용과 응답을 확인하는 페이지입니다.
- **기도 상세**: 제목, 내용, 카테고리, 응답 수
- **응답 목록**: 다른 사용자들의 기도 응답 표시
- **응답하기**: 해당 기도에 응답 추가
- **삭제**: 자신의 기도인 경우 삭제 가능

**ViewModel**: `PrayerDetailViewModel`

### 4. 기도 작성 페이지 (`PrayerEditorView`)
새로운 기도 요청을 작성하는 페이지입니다.
- **제목 입력**: 간단한 기도 제목
- **내용 입력**: 상세한 기도 내용
- **카테고리 선택**: 적절한 카테고리 선택
- **제출**: 기도 요청 등록

**ViewModel**: `PrayerEditorViewModel`

### 5. 내 기도 탭 (`MyPrayerView`)
사용자가 올린 기도와 받은 응답을 관리하는 페이지입니다.
- **내가 올린 기도**: 자신이 작성한 기도 요청 목록
- **내가 한 응답**: 다른 기도에 대한 자신의 응답 목록
- **응답 수 확인**: 각 기도가 받은 응답의 개수
- **기도 삭제**: 불필요한 기도 요청 제거

**ViewModel**: `MyPrayerViewModel`

### 6. 마이페이지 탭 (`MyPageView`)
프로필 및 계정 설정을 관리하는 페이지입니다.
- **사용자 정보**: 이름, 이메일 등
- **설정**: 알림 설정, 언어 설정 등
- **로그아웃**: 계정에서 로그아웃

**ViewModel**: `MyPageViewModel`

---

## 🔐 인증 흐름

1. **로그인**: LoginViewModel → APIClient.login() → TokenStorage에 토큰 저장
2. **토큰 검증**: RootView에서 앱 시작 시 TokenStorage의 토큰 확인
3. **API 요청**: APIClient가 자동으로 모든 요청에 토큰 헤더 추가
4. **로그아웃**: TokenStorage에서 토큰 삭제 → UserSession 초기화

---

## 🚀 빌드 및 실행

### 요구사항
- Xcode 13+
- iOS 14+
- Swift 5.0+

---

## 📋 기술 스택

| 영역 | 기술 |
|-----|------|
| **UI Framework** | SwiftUI |
| **아키텍처** | Clean Architecture |
| **비동기** | async/await |
| **반응형** | Combine, @Published |
| **HTTP** | URLSession |
| **로컬 저장소** | Keychain, UserDefaults |
| **언어** | Swift 5.0+ |
| **최소 배포** | iOS 14+ |




