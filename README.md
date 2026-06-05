# Dionomy

성인 취미 학원을 위한 모듈형 운영 앱 세팅 서비스입니다.

이 루트 저장소는 프론트엔드와 백엔드를 직접 담는 코드 저장소가 아니라, 전체 프로젝트의 조합과 공통 문서를 관리하는 메타 저장소로 사용합니다.

## 저장소 구조

```txt
dionomy/
  README.md
  docs/
  frontend/   # 별도 GitHub 저장소, Git submodule
  backend/    # 별도 GitHub 저장소, Git submodule
```

## 저장소 역할

- 루트 저장소: 전체 프로젝트 문서, 공통 설정, 프론트/백엔드 submodule 커밋 포인터 관리
- 프론트엔드 저장소: 웹앱, 관리자 웹, 수강생 모바일 웹/PWA
- 백엔드 저장소: API, 인증/권한, 멀티테넌트, 운영 모듈, 설정 관리

## 로컬 개발 시작

처음 받은 뒤에는 submodule과 로컬 환경을 준비한다.

```bash
git submodule update --init --recursive
just setup
```

`just setup`은 다음을 수행한다.

- `.env`가 없으면 `.env.example`에서 생성
- 프론트 의존성 설치 (`npm ci` 또는 `npm install`)
- PostgreSQL Docker 컨테이너 실행
- DB readiness 확인
- `just doctor` 실행

## 환경 변수

`.env.example`을 기준으로 `.env`를 만든다.

```bash
cp .env.example .env
```

주요 값:

- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`: Docker PostgreSQL 초기화 값
- `DIONOMY_DATABASE_URL`, `DIONOMY_DATABASE_USERNAME`, `DIONOMY_DATABASE_PASSWORD`: 백엔드 DB 접속 값
- `JAVA_HOME`: 선택값. 지정하면 backend Gradle 실행 시 우선 사용한다.

`POSTGRES_PASSWORD`와 `DIONOMY_DATABASE_PASSWORD`는 로컬 개발에서는 같게 둔다.  
이미 만들어진 Docker volume의 비밀번호와 `.env`가 어긋나면 백엔드가 `password authentication failed`로 실패할 수 있다. 이 경우 로컬 데이터 삭제가 가능하면 `just db-reset`을 사용한다.

## 개발 명령어

```bash
just doctor       # 로컬 환경 진단
just setup        # 최초 세팅 또는 환경 복구
just dev          # DB + backend + frontend 실행
just frontend-dev # frontend만 실행
just backend-dev  # backend만 실행
just test         # frontend/backend 테스트
just build        # frontend 빌드
```

`just dev`는 실행 전에 `5173`, `8080` 포트를 확인한다.  
이미 dev 서버가 떠 있으면 PID를 출력하고 중단한다. 기존 서버를 그대로 쓰거나, 직접 종료한 뒤 다시 실행한다.

## Doctor 확인 항목

`just doctor`는 다음을 확인한다.

- 필수 도구: `just`, `docker`, `docker compose`, `node`, `npm`, `curl`
- Java 21: `.env`의 `JAVA_HOME` 우선, 없으면 PATH의 `java`
- `.env` 필수 값
- Docker PostgreSQL 실행 상태와 readiness
- 포트: `5173`, `8080`, `5432`, `35729`
- backend API: `/actuator/health`, `/api/academy/settings`
- 프로젝트 파일: `backend/gradlew`, `frontend/package.json`, `frontend/node_modules`

문제가 있으면 마지막에 권장 조치를 출력한다.

## 문서

- [작업 규칙](AGENTS.md)
- [구현 정책](docs/implementation-policy.md)
- [MVP 기능 체크리스트](docs/mvp-checklist.md)
- [기술 스택](docs/technical-stack.md)
- [MVP 구현 로드맵](docs/implementation-roadmap.md)
- [Figma 화면 연결](docs/figma-screen-map.md)
- [배포 가이드](docs/deployment.md)
- [Git 작업 공간 전략](docs/git-workspace-strategy.md)
