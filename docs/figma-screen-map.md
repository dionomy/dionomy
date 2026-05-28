# Figma 화면 연결 문서

## 기준 파일

- Figma 파일: Dionomy
- URL: `https://www.figma.com/design/QBT0ND6Qxl5IbJfSjNj0GS/Dionomy?node-id=1-3&m=dev`
- file key: `QBT0ND6Qxl5IbJfSjNj0GS`
- 기준 page node: `1:3`
- page name: `Screens`
- 디자인 시스템 page node: `0:1`
- 디자인 시스템 page name: `Design System`

## 사용 원칙

- 구현 전 해당 화면의 Figma frame id를 먼저 확인한다.
- 화면 구현 전 `Design System(0:1)`의 토큰과 공통 컴포넌트 기준을 먼저 확인한다.
- React 구현 시 Figma frame 이름을 화면/feature 기준으로 매핑한다.
- CSS 토큰은 Figma의 `--color-*`, `--radius-*` 이름을 우선 사용한다.
- 와이어프레임은 초기 IA 참고용으로만 사용하고, 실제 UI 구현은 `Web / ...` 프레임과 규칙 프레임을 우선한다.
- 시간표 구현은 별도 규칙 프레임의 동시간대/부분 겹침 규칙을 반드시 반영한다.

## 디자인 시스템 연결

기준 URL: `https://www.figma.com/design/QBT0ND6Qxl5IbJfSjNj0GS/Dionomy?node-id=0-1&m=dev`

| Figma frame | Node ID | 구현 기준 |
| --- | --- | --- |
| `Design System` | `0:1` | 전체 디자인 시스템 페이지 |
| `Color Palette` | `28:5` | Radix 12-step 색상 토큰. brand는 화이트라벨 override |
| `Component: Mobile ListRow` | `149:11` | 모바일 터치 리스트 행, 64pt 높이 |
| `Component: Mobile StatCard` | `149:126` | 모바일 KPI 카드, 175pt x 96pt |
| `Component: Mobile SegmentedControl` | `149:151` | 모바일 pill 탭, 36pt 높이 |
| `Component: Mobile PageHeader` | `148:5` | 모바일 sticky page header, 56pt 높이 |
| `Component: Mobile SectionHeader` | `148:21` | 모바일 섹션 타이틀 + 전체보기 링크 |
| `Component: Mobile SearchBar` | `148:32` | 모바일 검색 입력, 40pt 높이 |
| `Component: Mobile FAB` | `148:42` | 모바일 56pt 원형 floating action button |

핵심 토큰:

- brand: `--color-brand-1`부터 `--color-brand-12`, 기본 solid는 `--color-brand-9 #5B5BD6`
- neutral: `--color-neutral-1`부터 `--color-neutral-12`
- success: `--color-success-1`부터 `--color-success-12`
- danger: `--color-danger-1`부터 `--color-danger-12`
- warning: `--color-warning-1`부터 `--color-warning-12`
- semantic alias: `--color-bg-app`, `--color-bg-subtle`, `--color-bg-element`, `--color-border-subtle`, `--color-border-default`, `--color-text-primary`, `--color-text-secondary`, `--color-text-brand`

## 주요 프레임 목록

| Figma frame | Node ID | 구현 화면 | React 위치 | 상태 |
| --- | --- | --- | --- | --- |
| `Screens` | `1:3` | 전체 화면 페이지 | 문서 기준 | 확인 |
| `Web / Login` | `109:229` | 원장/관리자 웹 로그인 | `frontend/src/pages/auth` | 미구현 |
| `Web / Sign up` | `109:298` | 원장 가입/온보딩 | `frontend/src/pages/auth` | 미구현 |
| `Web / Dashboard` | `82:2` | 원장 대시보드 | `frontend/src/pages/owner/OwnerDashboardPage.tsx` | 일부 구현 |
| `Web / Schedule` | `86:2` | 원장 통합일정/시간표 | `frontend/src/features/schedule`, `frontend/src/pages/owner` | 미구현 |
| `Web / Class List` | `88:2` | 클래스 목록 | `frontend/src/features/classes` | 미구현 |
| `Web / Class Detail` | `103:63` | 클래스 상세 | `frontend/src/features/classes` | 미구현 |
| `Web / Student List` | `95:2` | 학생 목록 | `frontend/src/features/students` | 미구현 |
| `Web / Student Detail` | `103:440` | 학생 상세 | `frontend/src/features/students` | 미구현 |
| `Web / Teacher` | `103:817` | 강사 관리 | `frontend/src/features/teachers` | 미구현 |
| `Web / Billing` | `103:1194` | 결제/수강증 | `frontend/src/features/passes` | MVP 일부 제외 |
| `Web / Settings` | `103:1571` | 학원 설정 | `frontend/src/features/academy-settings` | 일부 구현 |
| `Mobile v2 / Onboarding` | `168:611` | 모바일 온보딩 | `frontend/src/pages/academy-app` | 미구현 |
| `Mobile v2 / Login` | `168:641` | 모바일 로그인 | `frontend/src/pages/academy-app` | 미구현 |
| `Mobile v2 / Home` | `168:683` | 모바일 홈 | `frontend/src/pages/academy-app/StudentHomePage.tsx` | 일부 구현 |
| `Mobile v2 / Notifications` | `168:818` | 모바일 알림 | `frontend/src/features/notices` | 미구현 |
| `Mobile v2 / Class List` | `169:678` | 모바일 클래스 목록 | `frontend/src/features/schedule` | 미구현 |
| `Mobile v2 / Class Detail` | `169:847` | 모바일 클래스 상세 | `frontend/src/features/schedule` | 미구현 |
| `Mobile v2 / Attendance Sheet` | `169:971` | 모바일 출석/수업 시트 | `frontend/src/features/attendance` | 미구현 |
| `Mobile v2 / Calendar` | `173:721` | 모바일 캘린더 | `frontend/src/features/schedule` | 미구현 |
| `Mobile v2 / Day Sheet` | `173:883` | 모바일 일자별 수업 시트 | `frontend/src/features/schedule` | 미구현 |
| `Mobile v2 / Student List` | `173:949` | 모바일 담당 학생 목록 | `frontend/src/features/students` | 미구현 |
| `Mobile v2 / Student Detail` | `174:764` | 모바일 학생 상세 | `frontend/src/features/students` | 미구현 |
| `Mobile v2 / Note Editor` | `174:884` | 클래스노트 작성 | `frontend/src/features/class-notes` | 미구현 |
| `Mobile v2 / Settings` | `174:956` | 모바일 설정 | `frontend/src/pages/academy-app` | 미구현 |
| `Mobile v2 / Profile` | `175:844` | 모바일 프로필 | `frontend/src/pages/academy-app` | 미구현 |
| `Mobile v2 / Empty + Add` | `175:981` | 모바일 빈 상태/추가 플로우 | 공통 UI | 미구현 |
| `Dashboard Main Block - 4 Variants` | `196:587` | 대시보드 위젯 변형 | `frontend/src/features/dashboard` | 미구현 |
| `Schedule / 동시간대 표시 규칙` | `235:587` | 시간표 겹침 표시 규칙 | `frontend/src/features/schedule` | 미구현 |
| `Schedule / 부분 겹침 레이아웃 알고리즘` | `248:587` | 시간표 구간 최적화 규칙 | `frontend/src/features/schedule` | 미구현 |
| `wireframe-full 1` | `80:560` | 웹 IA 초안 | 참고용 | 확인 |
| `wireframe-full 2` | `112:258` | 웹 IA 초안 2 | 참고용 | 확인 |
| `wireframe-mobile 1` | `80:559` | 모바일 앱 IA 초안 | `frontend/src/pages/academy-app` | 참고용 |

## 전체 직계 하위 노드

`Screens(1:3)`의 직계 하위는 다음 32개다.

| Node ID | Name | Type | Size |
| --- | --- | --- | --- |
| `80:559` | `wireframe-mobile 1` | RECTANGLE | 1712 x 3511 |
| `80:560` | `wireframe-full 1` | RECTANGLE | 2718 x 2508 |
| `112:258` | `wireframe-full 2` | RECTANGLE | 1577 x 2508 |
| `82:2` | `Web / Dashboard` | FRAME | 1440 x 900 |
| `86:2` | `Web / Schedule` | FRAME | 1440 x 980 |
| `88:2` | `Web / Class List` | FRAME | 1440 x 980 |
| `95:2` | `Web / Student List` | FRAME | 1440 x 1168 |
| `103:63` | `Web / Class Detail` | FRAME | 1440 x 1103 |
| `103:440` | `Web / Student Detail` | FRAME | 1440 x 1122 |
| `103:817` | `Web / Teacher` | FRAME | 1440 x 980 |
| `103:1194` | `Web / Billing` | FRAME | 1440 x 1136 |
| `103:1571` | `Web / Settings` | FRAME | 1440 x 1365 |
| `109:229` | `Web / Login` | FRAME | 1440 x 900 |
| `109:298` | `Web / Sign up` | FRAME | 1440 x 900 |
| `168:611` | `Mobile v2 / Onboarding` | FRAME | 390 x 890 |
| `168:641` | `Mobile v2 / Login` | FRAME | 390 x 652 |
| `168:683` | `Mobile v2 / Home` | FRAME | 390 x 894 |
| `168:818` | `Mobile v2 / Notifications` | FRAME | 390 x 988 |
| `169:678` | `Mobile v2 / Class List` | FRAME | 390 x 1018 |
| `169:847` | `Mobile v2 / Class Detail` | FRAME | 390 x 972 |
| `169:971` | `Mobile v2 / Attendance Sheet` | FRAME | 390 x 845 |
| `173:721` | `Mobile v2 / Calendar` | FRAME | 390 x 1099 |
| `173:883` | `Mobile v2 / Day Sheet` | FRAME | 390 x 659 |
| `173:949` | `Mobile v2 / Student List` | FRAME | 390 x 1088 |
| `174:764` | `Mobile v2 / Student Detail` | FRAME | 390 x 1090 |
| `174:884` | `Mobile v2 / Note Editor` | FRAME | 390 x 582 |
| `174:956` | `Mobile v2 / Settings` | FRAME | 390 x 1272 |
| `175:844` | `Mobile v2 / Profile` | FRAME | 390 x 1019 |
| `175:981` | `Mobile v2 / Empty + Add` | FRAME | 390 x 928 |
| `196:587` | `Dashboard Main Block - 4 Variants` | FRAME | 3020 x 552 |
| `235:587` | `Schedule / 동시간대 표시 규칙` | FRAME | 643 x 600 |
| `248:587` | `Schedule / 부분 겹침 레이아웃 알고리즘` | FRAME | 612 x 422 |

## 웹 화면 연결

### 인증

| 화면 | Node ID | 목적 | 구현 연결 |
| --- | --- | --- | --- |
| `Web / Login` | `109:229` | 원장/관리자 로그인 | `features/auth`, `pages/auth` |
| `Web / Sign up` | `109:298` | 학원 가입/초기 온보딩 | `features/auth`, `features/tenant-onboarding` |

### 원장 운영 웹

| 화면 | Node ID | 목적 | 구현 연결 |
| --- | --- | --- | --- |
| `Web / Dashboard` | `82:2` | 운영 현황 요약 | `features/dashboard` |
| `Web / Schedule` | `86:2` | 통합일정/시간표 | `features/schedule` |
| `Web / Class List` | `88:2` | 클래스 목록 | `features/classes` |
| `Web / Class Detail` | `103:63` | 클래스 상세, 수강생 배정, 수업 기록 연결 | `features/classes`, `features/class-notes` |
| `Web / Student List` | `95:2` | 학생 목록/검색/필터 | `features/students` |
| `Web / Student Detail` | `103:440` | 수강권, 출결, 케어 기록 | `features/students`, `features/passes`, `features/crm` |
| `Web / Teacher` | `103:817` | 강사 목록/진행 현황/권한 | `features/teachers` |
| `Web / Billing` | `103:1194` | 수강증/수강권/결제성 정보 | `features/passes` |
| `Web / Settings` | `103:1571` | 학원 정보, 브랜딩, 운영 정책 | `features/academy-settings` |

주의:

- `Web / Billing`은 Figma에 존재하지만 MVP 결제 영역은 제외다.
- MVP에서는 결제 처리 없이 수강권 상품/발급/사용 이력 UI로 범위를 제한한다.
- `Web / Settings`는 현재 `OwnerSettingsPage`와 `AcademySettingsForm`으로 일부 반영되어 있다.

## 모바일 화면 연결

모바일 프레임은 수강생 앱과 강사 모드가 섞여 있다. 로그인 역할에 따라 노출 메뉴를 달리한다.

| 화면 | Node ID | 목적 | 대상 역할 | 구현 연결 |
| --- | --- | --- | --- | --- |
| `Mobile v2 / Onboarding` | `168:611` | 앱 첫 진입/학원 연결 | 공통 | `pages/academy-app` |
| `Mobile v2 / Login` | `168:641` | 카카오 로그인 | 공통 | `features/auth` |
| `Mobile v2 / Home` | `168:683` | 다음 수업, 수강권 요약 | 수강생 | `StudentHomePage` |
| `Mobile v2 / Notifications` | `168:818` | 공지/알림 목록 | 공통 | `features/notices` |
| `Mobile v2 / Class List` | `169:678` | 내 수업/클래스 목록 | 수강생/강사 | `features/schedule` |
| `Mobile v2 / Class Detail` | `169:847` | 수업 상세 | 수강생/강사 | `features/schedule` |
| `Mobile v2 / Attendance Sheet` | `169:971` | 출석 체크 | 강사 | `features/attendance` |
| `Mobile v2 / Calendar` | `173:721` | 내 일정 캘린더 | 수강생/강사 | `features/schedule` |
| `Mobile v2 / Day Sheet` | `173:883` | 날짜별 수업 목록 | 수강생/강사 | `features/schedule` |
| `Mobile v2 / Student List` | `173:949` | 담당 학생 목록 | 강사 | `features/students` |
| `Mobile v2 / Student Detail` | `174:764` | 담당 학생 상세 | 강사 | `features/students` |
| `Mobile v2 / Note Editor` | `174:884` | 클래스노트 작성 | 강사 | `features/class-notes` |
| `Mobile v2 / Settings` | `174:956` | 앱 설정 | 공통 | `pages/academy-app` |
| `Mobile v2 / Profile` | `175:844` | 프로필/로그아웃 | 공통 | `pages/academy-app` |
| `Mobile v2 / Empty + Add` | `175:981` | 빈 상태와 추가 플로우 | 공통 | `shared/ui` |

MVP 반영:

- 수강생 홈
- 내 일정
- 결석 신청 상태
- 내 수강권
- 클래스노트 읽기
- 강사 오늘 수업
- 강사 출석 체크
- 강사 클래스노트 작성
- 강사 결석 신청 승인 큐

## Web / Dashboard

Node ID: `82:2`

역할:

- 원장 운영 웹의 기본 진입 화면
- 학원 운영 지표, 오늘 수업, 출석 현황, 만료 임박 정보를 요약한다.

구조:

```txt
Web / Dashboard
  Sidebar
    Logo / academy name
    MAIN
      대시보드
      시간표
    OPERATION
      클래스
      학생
      강사
      결제 · 수강증
    설정
  Content
    Topbar
      Page title
      Search
      Notification
      Profile
    Greeting
      원장 인사
      날짜
      새 수업 추가
    Metric cards
      전체 학생 수
      이번 주 출석률
      이번 달 매출
      수강권 만료 임박
    Main widgets
      이번 주 출석 현황
      오늘의 수업
```

현재 구현 매핑:

- `Sidebar` → `MainShell`
- `Metric cards` → `DashboardSummary`
- `오늘의 수업` → `WeeklySchedulePreview`
- `To-do`는 기존 MVP 정책 기반으로 구현 중이나, Figma Dashboard에는 아직 명시 위젯이 약함

보강 필요:

- topbar 검색 영역
- 알림/프로필 영역
- Figma 기준 metric 4종으로 변경
- 출석 현황 차트
- 오늘의 수업 카드 스타일
- `새 수업 추가` CTA

## Web / Schedule

Node ID: `86:2`

역할:

- 원장 통합일정 화면
- 주간/월간 시간표, 수업 생성, 수업 배정, 충돌 확인의 중심 화면

구조:

```txt
Web / Schedule
  Sidebar
    Dashboard와 동일
  Content
    Topbar
    Schedule controls
    Calendar / weekly timetable
    Class cards
    Session detail / modal or side panel
```

구현 연결:

- route 후보: `/owner/schedule`
- page 후보: `frontend/src/pages/owner/OwnerSchedulePage.tsx`
- feature:
  - `features/schedule`
  - `features/teachers`
  - `features/students`
  - `features/attendance`
  - `features/absence`

MVP 반영 항목:

- 주간/월간 캘린더
- 수업 등록
- 반복 일정 등록
- 수업 이동/취소
- 수강생 배정
- 정원 표시
- 강사/장소 충돌 경고

## 시간표 동시간대 표시 규칙

Node ID: `235:587`

프레임명: `Schedule / 동시간대 표시 규칙`

규칙:

- 같은 시간대 수업이 1개면 셀 전체 폭을 사용한다.
- 같은 시간대 수업이 2개면 셀 내부를 좌우 50/50으로 분할한다.
- 같은 시간대 수업이 3개 이상이면 2개까지 표시하고 `+N` 칩을 표시한다.
- `+N` 칩을 클릭하면 전체 동시간대 수업 목록을 팝오버로 보여준다.
- 팝오버는 hover가 아니라 click으로 열고 고정한다.
- 팝오버에서는 같은 시간대 전체 수업을 비교할 수 있어야 한다.

구현 기준:

```txt
1 class  -> full width card
2 class  -> two compact cards
3+ class -> two compact cards + "+N" chip
```

필요 컴포넌트:

- `ScheduleGrid`
- `ScheduleSlot`
- `ScheduleClassCard`
- `ScheduleOverflowChip`
- `ScheduleOverlapPopover`

## 부분 겹침 레이아웃 알고리즘

Node ID: `248:587`

프레임명: `Schedule / 부분 겹침 레이아웃 알고리즘`

규칙:

- 겹치면 무조건 새 열을 만드는 단순 분할은 사용하지 않는다.
- 시간 구간의 실제 overlap을 계산한다.
- 최대 동시 수업 수를 기준으로 열 수를 결정한다.
- 이전 수업이 끝난 뒤에는 같은 열을 재사용한다.

예시:

```txt
A 16:00-18:00
B 17:30-19:30
C 19:00-21:00

A와 B는 겹침
B와 C는 겹침
A와 C는 겹치지 않음

최대 동시 수업 수 = 2
열 수 = 2
C는 A가 끝난 뒤 A의 열을 재사용
```

구현 기준:

- interval graph coloring 방식으로 column을 배정한다.
- calendar event layout은 단순 `index / count` 분할이 아니라 overlap group 단위로 계산한다.
- 같은 overlap group 안에서 재사용 가능한 column을 찾아 배정한다.

필요 함수 후보:

```txt
buildOverlapGroups(events)
assignScheduleColumns(events)
calculateEventRect(event, group)
```

## Wireframe 연결

### `wireframe-full 1`

Node ID: `80:560`

용도:

- 웹 운영툴 IA 초안
- 좌측 사이드바, 대시보드, 수업, 수강생, 강사, 설정 구조 참고

구현 반영:

- `MainShell`
- 원장 운영 웹 메뉴 구조

### `wireframe-full 2`

Node ID: `112:258`

용도:

- 웹 상세 흐름 추가 초안
- 수업 상세, 배정/모달/상세 패널 참고

구현 반영 예정:

- 수업 상세 패널
- 수강생 배정 UI
- 결석/보강 처리 UI

### `wireframe-mobile 1`

Node ID: `80:559`

용도:

- 수강생/강사 모바일 앱 IA 초안
- 상단 로고, 하단 탭, 홈/일정/클래스노트/공지/마이페이지 구조 참고

구현 반영:

- `StudentHomePage`
- 향후 `TeacherHomePage` 모바일 대응

## 구현 우선순위

1. `Web / Dashboard`를 Figma 기준으로 보정한다.
2. `Web / Schedule` 화면을 생성한다.
3. 시간표 동시간대 표시 규칙을 구현한다.
4. 부분 겹침 레이아웃 알고리즘을 구현한다.
5. `Web / Class List`, `Web / Class Detail`을 구현한다.
6. `Web / Student List`, `Web / Student Detail`을 구현한다.
7. `Web / Teacher`를 구현한다.
8. `Web / Settings`를 현재 설정 화면에 맞춰 보정한다.
9. 모바일 `Home`, `Calendar`, `Class Detail`을 구현한다.
10. 모바일 강사 모드 `Attendance Sheet`, `Student List`, `Note Editor`를 구현한다.
11. 공통 모바일 `Notifications`, `Settings`, `Profile`, `Empty + Add`를 구현한다.

## Figma 조회 명령 기준

디자인 구현 전 다음 도구를 우선 사용한다.

```txt
get_design_context(fileKey=QBT0ND6Qxl5IbJfSjNj0GS, nodeId=<frame id>)
get_screenshot(fileKey=QBT0ND6Qxl5IbJfSjNj0GS, nodeId=<frame id>)
get_metadata(fileKey=QBT0ND6Qxl5IbJfSjNj0GS, nodeId=1:3)
```

주요 node id:

```txt
Screens: 1:3
Web / Login: 109:229
Web / Sign up: 109:298
Web / Dashboard: 82:2
Web / Schedule: 86:2
Web / Class List: 88:2
Web / Class Detail: 103:63
Web / Student List: 95:2
Web / Student Detail: 103:440
Web / Teacher: 103:817
Web / Billing: 103:1194
Web / Settings: 103:1571
Mobile v2 / Onboarding: 168:611
Mobile v2 / Login: 168:641
Mobile v2 / Home: 168:683
Mobile v2 / Notifications: 168:818
Mobile v2 / Class List: 169:678
Mobile v2 / Class Detail: 169:847
Mobile v2 / Attendance Sheet: 169:971
Mobile v2 / Calendar: 173:721
Mobile v2 / Day Sheet: 173:883
Mobile v2 / Student List: 173:949
Mobile v2 / Student Detail: 174:764
Mobile v2 / Note Editor: 174:884
Mobile v2 / Settings: 174:956
Mobile v2 / Profile: 175:844
Mobile v2 / Empty + Add: 175:981
Dashboard Main Block variants: 196:587
Schedule same-time rule: 235:587
Schedule overlap algorithm: 248:587
Mobile wireframe: 80:559
Web wireframe 1: 80:560
Web wireframe 2: 112:258
```
