# 다음 구현 로드맵

작성일: 2026-05-28

## 현재 상태

완료된 것:

- 루트 메타 저장소와 `frontend`, `backend` submodule 구조
- React/Vite 프론트엔드 앱 골격
- Kotlin Spring Boot 백엔드 앱 골격
- Docker Compose 기반 PostgreSQL 로컬 개발 환경
- asdf 기반 Node/Java 버전 고정
- `just` 기반 루트/서브모듈 실행 스크립트
- Figma 디자인 시스템 토큰 반영
- 원장 운영 웹 주요 정적 화면
- 수강생/강사/관리자 주요 정적 화면
- 일정, 수강생, 수강권, 출석, 결석, 클래스노트, 공지, 회사 웹, 관리자 세팅 API 골격
- 백엔드 JPA/Flyway 연결 확인
- 백엔드 API는 대부분 인메모리 저장소 사용
- 프론트엔드는 대부분 정적 화면이며 API 연동 전

검증된 것:

- `just test`
- Docker PostgreSQL healthcheck
- backend local profile bootRun
- `/actuator/health`
- frontend build

## 진행 원칙

각 마일스톤은 다음 루프로 진행한다.

```txt
계획
구현
검증
commit-plan-and-split 기준 커밋 분할
커밋
```

커밋 계획 보고 시 반드시 다음을 구분한다.

- `frontend` submodule 커밋
- `backend` submodule 커밋
- root 메타 저장소 커밋
- root에서 갱신되는 submodule 포인터

## 마일스톤 A. 백엔드 영속화 전환

목표:

- 인메모리 저장소를 JPA 기반 저장소로 전환한다.
- Flyway migration을 작성한다.
- 재시작해도 데이터가 유지되게 한다.

범위:

- tenant
- academy settings
- schedule
- student
- pass
- attendance
- absence
- classnote
- notice
- company intake
- admin setup

산출물:

- JPA Entity
- Spring Data JPA Repository
- domain repository adapter
- Flyway `V1__init.sql`
- repository/usecase 테스트

우선순위:

1. tenant, academy
2. student, pass
3. schedule
4. attendance, absence
5. classnote, notice
6. company, admin setup

## 마일스톤 B. 프론트 API 연동 기반

목표:

- 프론트가 백엔드 API를 호출할 수 있는 공통 레이어를 만든다.

범위:

- API client
- tenant header 처리
- React Query provider
- query key 규칙
- 공통 loading/error/empty state
- form validation 기준

산출물:

- `shared/api`
- `shared/query`
- feature별 API adapter
- dev mock 제거 또는 dev-only 처리

## 마일스톤 C. 일정/수업 실제 동작화

목표:

- 원장이 수업을 등록하고 캘린더에서 조회할 수 있게 한다.

범위:

- 수업 등록 폼
- 주간/월간 조회
- 반복 일정 등록
- 수업 이동/취소
- 수강생 배정
- 강사/장소 충돌 경고
- 정원 표시

산출물:

- schedule API 연동
- schedule mutation
- schedule form modal
- calendar refresh
- 충돌 에러 UI

## 마일스톤 D. 수강생/수강권 실제 동작화

목표:

- 수강생 등록부터 수강권 발급/차감/복구까지 실제 데이터로 동작하게 한다.

범위:

- 수강생 등록/조회/상세
- 수강권 상품 등록
- 수강권 발급
- 사용 이력 조회
- 차감/복구
- 만료 임박 표시

산출물:

- student API 연동
- pass API 연동
- 수강생 상세 화면
- 수강권 상품/발급 폼
- 사용 이력 UI

## 마일스톤 E. 출석/결석/보강 실제 동작화

목표:

- 강사와 수강생의 핵심 운영 플로우를 연결한다.

범위:

- 강사 오늘 수업 목록
- 출석 체크 저장
- 수강생 내 일정
- 결석 신청
- 결석 신청 상태 표시
- 강사 승인/거절
- 다른 세션 이동 또는 보강 처리
- 출석 시 수강권 차감
- 승인된 결석/보강 시 회차 복구 정책 적용

산출물:

- teacher mode API 연동
- student schedule API 연동
- absence mutation
- attendance mutation
- pass usage 연동

## 마일스톤 F. 클래스노트/공지 실제 동작화

목표:

- 클래스노트와 공지를 실제 작성/조회할 수 있게 한다.

범위:

- 강사 클래스노트 작성
- 클래스노트 이전 기록 조회
- 수강생 클래스노트 읽기
- 원장 공지 작성
- 전체/특정 클래스 대상 공지
- 수강생 공지 목록/상세

산출물:

- classnote API 연동
- notice API 연동
- 작성 폼
- 타임라인/목록/상세 화면

## 마일스톤 G. 인증과 권한

목표:

- mock role switcher를 개발 전용으로 격리하고 실제 인증 체계를 준비한다.

범위:

- dev role switcher 분리
- 카카오 로그인
- JWT 또는 세션 정책 확정
- role 기반 라우팅
- tenant scope 검증
- API 권한 검사

산출물:

- auth API
- 프론트 auth store 정리
- backend security config 정리
- 원장/강사/수강생/관리자 권한 테스트

## 마일스톤 H. CRM 위험 신호

목표:

- MVP 핵심 차별점인 이탈 신호를 실제 데이터 기반으로 계산한다.

범위:

- 휴면
- 만료 임박
- 변동 잦음
- 보강 누적
- 신규 정착 중
- 케어 기록
- 처리 상태
- 매일 갱신 배치

산출물:

- crm domain
- signal rule
- scheduled batch
- 위험 수강생 리스트
- 대시보드 To-do 연동

## 마일스톤 I. 회사 웹/관리자 세팅 실제 동작화

목표:

- Dionomy 운영팀이 신규 학원 유입과 세팅 상태를 관리할 수 있게 한다.

범위:

- 회사 랜딩
- 데모 신청
- CS 문의 등록/조회
- 학원 목록
- 신규 학원 온보딩
- 화이트라벨 설정
- 빌드 상태 모니터

산출물:

- company API 연동
- admin setup API 연동
- 관리자 테이블/폼
- CS 티켓 큐

## 마일스톤 J. 통합 검증과 배포 준비

목표:

- MVP 핵심 플로우를 end-to-end로 검증하고 배포 가능한 형태로 정리한다.

검증 플로우:

- 원장이 수업 생성
- 원장이 수강생 배정
- 원장이 수강권 발급
- 강사가 출석 체크
- 출석 시 수강권 차감
- 수강생이 결석 신청
- 강사가 승인
- 보강 또는 다른 세션 이동 처리
- 강사가 클래스노트 작성
- 수강생이 클래스노트 확인
- 원장이 공지 작성
- 수강생이 공지 확인
- 위험 신호가 대시보드에 표시

산출물:

- API 테스트
- 프론트 핵심 화면 테스트
- 통합 시나리오 테스트
- 환경변수 정리
- Docker production 기준
- CI
- 배포 문서

## 즉시 다음 작업

가장 먼저 진행할 작업:

1. 백엔드 JPA/Flyway 영속화 전환
2. 프론트 API client/React Query 기반 구축
3. 일정/수업 CRUD 연동

이 순서로 진행해야 정적 화면이 실제 운영 앱으로 전환된다.
