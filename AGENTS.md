# AGENTS.md

## 답변 규칙

- 한국어만 사용한다.
- 핵심만 간결하게 답한다.
- 불필요한 설명은 생략한다.

## 프로젝트 성격

Dionomy는 성인 취미 학원을 위한 모듈형 운영 앱 세팅 서비스다.

원장이 직접 앱을 만드는 노코드 빌더가 아니라, Dionomy 운영팀이 학원별 기능, 워딩, 정책, 화면 구성을 세팅하고 원장·강사·수강생은 운영 기능만 사용하는 구조다.

## 저장소 구조

이 프로젝트는 루트 메타 저장소 + 하위 독립 저장소 구조를 사용한다.

```txt
dionomy/
  AGENTS.md
  README.md
  docs/
  frontend/   # 별도 Git 저장소, submodule
  backend/    # 별도 Git 저장소, submodule
```

루트 저장소는 문서, 공통 정책, submodule 포인터를 관리한다.  
프론트엔드와 백엔드는 각각 독립 Git 저장소로 관리한다.

## 기술 스택

프론트엔드:

- React
- Vite
- TypeScript
- Tailwind CSS
- feature-based 구조

백엔드:

- Kotlin
- Spring Boot
- PostgreSQL
- Redis
- feature-based + DDD 구조

## 구현 원칙

- MVP는 앱스토어 출시보다 운영 가능한 웹/PWA 구현을 우선한다.
- Next.js는 사용하지 않는다.
- 프론트엔드는 React SPA/PWA로 구현한다.
- 백엔드는 Kotlin Spring Boot 모듈러 모놀리스로 시작한다.
- 프론트엔드 폴더 구조는 feature-based를 따른다.
- 백엔드 패키지는 feature-based로 나누고, 각 feature 내부는 DDD 원칙을 적용한다.
- 학원별 차이는 코드 분기가 아니라 설정값으로 처리한다.
- 원장은 기능/워딩/화면 구조를 직접 수정하지 않는다.
- 수강생 자율예약은 MVP에서 제외한다.
- 결제, 자동 케어 발송, LLM 분석, 네이티브 앱 직접 개발은 MVP에서 제외한다.

## 백엔드 DDD 구조

각 feature 내부는 다음 구조를 따른다.

```txt
feature/
  domain/
  application/
  infrastructure/
  presentation/
```

역할:

- `domain`: 핵심 규칙, 엔티티, 값 객체, repository interface
- `application`: 유스케이스, 트랜잭션, 권한 검사, 흐름 조합
- `infrastructure`: DB, 외부 API, 메시징, 파일 저장소 구현
- `presentation`: REST API controller, request/response DTO

피할 것:

- 전역 `controller/service/repository` 폴더 구조
- 모든 로직이 service에 몰리는 구조
- JPA Entity를 API 응답으로 직접 반환
- domain이 Spring, JPA, HTTP에 의존
- feature 간 repository 직접 참조

## 커밋 규칙

커밋 시점에는 반드시 `commit-plan-and-split` 스킬을 사용한다.

커밋 전에는 다음을 확인한다.

- `git status --short`
- `git diff --stat`
- 각 submodule의 `git status --short`

커밋은 최소 기능 단위로 나눈다.

## 커밋 계획 보고 형식

이 레포에서 커밋 계획을 보고할 때는 반드시 root와 submodule을 구분한다.

```txt
frontend 서브모듈
- 커밋 메시지
- 포함 변경
- 목적

backend 서브모듈
- 커밋 메시지
- 포함 변경
- 목적

root 메타 저장소
- 커밋 메시지
- 포함 변경
- 목적
- 갱신되는 submodule 포인터
```

실행 순서도 함께 명시한다.

```txt
1. frontend 내부 커밋
2. backend 내부 커밋
3. root에서 frontend/backend 포인터 커밋
```

## submodule 커밋 방식

프론트엔드 변경은 `frontend/` 안에서 커밋한다.

```bash
cd frontend
git add .
git commit -m "Add frontend app scaffold"
```

백엔드 변경은 `backend/` 안에서 커밋한다.

```bash
cd backend
git add .
git commit -m "Add backend DDD scaffold"
```

그 다음 루트에서 submodule 포인터를 커밋한다.

```bash
cd ..
git add frontend backend .gitmodules
git commit -m "Track frontend and backend submodules"
```

루트 저장소는 `frontend`와 `backend` 파일 내용을 직접 저장하지 않고, 각 submodule의 커밋 해시만 저장한다.

## 문서 기준

구현 시 다음 문서를 기준으로 삼는다.

- `docs/implementation-policy.md`
- `docs/mvp-checklist.md`
- `docs/technical-stack.md`
- `docs/implementation-roadmap.md`
- `docs/git-workspace-strategy.md`
