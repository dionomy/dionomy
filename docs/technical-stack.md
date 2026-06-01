# 기술 스택

## 결론

```txt
Frontend: React + Vite + TypeScript + Tailwind CSS
Backend: Kotlin + Spring Boot
Database: PostgreSQL
Cache: Redis
App: PWA 우선, 이후 WebView wrapper
AI: v2에서 Python FastAPI 별도 분리
```

Next.js는 사용하지 않는다.  
현재 제품은 로그인 이후 운영 화면 중심이고, SSR보다 빠른 SPA 개발과 PWA 전환이 중요하다.

## 프론트엔드

### 기본 스택

- React
- Vite
- TypeScript
- Tailwind CSS
- Radix UI 또는 shadcn/ui
- TanStack Router
- TanStack Query
- Zustand
- React Hook Form
- Zod
- PWA
- Playwright

### 구조 원칙

프론트엔드는 feature-based 구조를 사용한다.

도메인 기능 단위로 화면, API, 상태, 타입, 컴포넌트를 모으고, 공통 요소만 `shared`로 분리한다.

```txt
frontend/
  src/
    app/
      router/
      providers/
      layouts/
    pages/
      company/
      owner/
      admin/
      academy-app/
      teacher/
    features/
      schedule/
      students/
      teachers/
      passes/
      attendance/
      absence/
      makeup/
      class-notes/
      notices/
      crm/
      academy-settings/
      tenant-onboarding/
    shared/
      api/
      ui/
      config/
      lib/
      types/
```

### feature 내부 구조

```txt
features/schedule/
  api/
  model/
  ui/
  routes/
  hooks/
  schemas/
  index.ts
```

## 백엔드

### 기본 스택

- Kotlin
- Spring Boot
- Gradle
- Java 21
- PostgreSQL
- Redis
- Flyway
- Spring Security
- OpenAPI
- JPA 또는 jOOQ
- Testcontainers

### 로컬 Java 실행 기준

백엔드 실행은 Java 21을 기준으로 한다.

루트 `.env`에 `JAVA_HOME`을 지정하면 `backend/justfile`이 해당 JDK를 우선 사용한다.  
`JAVA_HOME`이 비어 있으면 PATH의 `java`를 사용한다.

asdf는 필수 조건으로 두지 않는다.

### 구조 원칙

백엔드는 Kotlin Spring Boot 기반 모듈러 모놀리스로 시작한다.

패키지는 feature-based로 나누되, 각 feature 내부는 DDD 원칙을 적용한다.

```txt
backend/
  src/main/kotlin/com/dionomy/
    DionomyApplication.kt
    global/
    auth/
    tenant/
    academy/
    user/
    schedule/
    student/
    teacher/
    pass/
    attendance/
    absence/
    makeup/
    classnote/
    notice/
    crm/
    notification/
```

### feature 내부 DDD 구조

```txt
schedule/
  domain/
    ClassSession.kt
    ClassType.kt
    SessionCapacity.kt
    SchedulePolicy.kt
    ScheduleRepository.kt
  application/
    CreateClassSessionUseCase.kt
    MoveClassSessionUseCase.kt
    CancelClassSessionUseCase.kt
    AssignStudentToSessionUseCase.kt
  infrastructure/
    ScheduleJpaEntity.kt
    ScheduleJpaRepository.kt
    ScheduleRepositoryAdapter.kt
  presentation/
    ScheduleController.kt
    request/
    response/
```

역할:

- `domain`: 핵심 규칙, 엔티티, 값 객체, 도메인 서비스, repository interface
- `application`: 유스케이스, 트랜잭션, 권한 검사, 도메인 흐름 조합
- `infrastructure`: DB, 외부 API, 메시징, 파일 저장소 구현
- `presentation`: REST API controller, request/response DTO

## DDD 적용 기준

지킬 것:

- 도메인 규칙은 `domain`에 둔다.
- 유스케이스 흐름은 `application`에 둔다.
- DB 구현은 `infrastructure`에 둔다.
- API DTO는 `presentation`에 둔다.
- 다른 feature의 DB 테이블을 직접 수정하지 않는다.
- feature 간 호출은 application 계층의 명확한 유스케이스를 통해 처리한다.

피할 것:

- 전역 `controller/service/repository` 폴더 구조
- 모든 로직이 service에 몰리는 구조
- JPA Entity를 API 응답으로 직접 반환
- 도메인 객체가 Spring, JPA, HTTP에 의존
- feature 간 repository 직접 참조

## 주요 도메인 경계

```txt
tenant          # 학원 테넌트, 상태, 화이트라벨 기본
academy         # 학원 정보, 브랜딩, 정책
user/auth       # 로그인, 권한, 사용자
schedule        # 수업 일정, 반복 일정, 충돌 검사
student         # 수강생 정보, 메모, 태그
teacher         # 강사 정보, 초대, 권한
pass            # 수강권 상품, 발급, 차감, 복구, 만료
attendance      # 출석, 지각, 결석
absence         # 결석 신청
makeup          # 보강, 다른 세션 이동
classnote       # 클래스노트
notice          # 공지
crm             # 위험 신호, 케어 기록
notification    # 알림 이벤트, 발송 준비
```

## 멀티테넌트 정책

초기에는 모든 주요 테이블에 `tenant_id`를 둔다.

모든 조회와 변경은 tenant scope 안에서만 수행한다.

MVP 이후 필요하면 PostgreSQL Row Level Security를 검토한다.

## 제외할 것

MVP에서 제외한다.

- Next.js
- Kubernetes
- 마이크로서비스
- GraphQL
- 네이티브 앱 직접 개발
- 결제 시스템
- LLM 이탈 예측
- 자동 케어 발송
