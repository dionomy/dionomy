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

## 문서

- [작업 규칙](AGENTS.md)
- [구현 정책](docs/implementation-policy.md)
- [MVP 기능 체크리스트](docs/mvp-checklist.md)
- [기술 스택](docs/technical-stack.md)
- [MVP 구현 로드맵](docs/implementation-roadmap.md)
- [Git 작업 공간 전략](docs/git-workspace-strategy.md)
