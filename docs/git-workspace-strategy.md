# Git 작업 공간 전략

## 목표

`dionomy` 루트 폴더는 모노레포처럼 한 작업 공간에서 개발하되, 프론트엔드와 백엔드는 각각 독립 Git 저장소로 관리한다.

GitHub 저장소는 다음처럼 분리한다.

```txt
dionomy            # 루트 메타 저장소
dionomy-frontend   # 프론트엔드 저장소
dionomy-backend    # 백엔드 저장소
```

## 기본 구조

```txt
dionomy/
  README.md
  docs/
  frontend/   # dionomy-frontend submodule
  backend/    # dionomy-backend submodule
```

루트 저장소는 `frontend`, `backend`의 실제 파일 전체를 저장하지 않는다.  
대신 각 submodule이 가리키는 Git 저장소 주소와 특정 커밋만 기록한다.

## GitHub에서 보이는 방식

GitHub 루트 저장소에서는 `frontend`, `backend`가 일반 폴더처럼 펼쳐지지 않고 링크처럼 보인다.

예시는 다음과 같다.

```txt
frontend @ a1b2c3d
backend  @ e4f5g6h
```

클릭하면 각각의 별도 GitHub 저장소와 해당 커밋으로 이동한다.

## 루트 커밋이 필요한 이유

프론트엔드나 백엔드에서 새 커밋을 만들면, 루트 저장소 입장에서는 submodule이 가리키는 커밋 포인터가 바뀐다.

예시:

```txt
frontend: a1b2c3d -> z9y8x7w
```

이 변경을 루트에 커밋하면, 루트 저장소가 "현재 전체 프로젝트는 이 프론트 커밋과 이 백엔드 커밋 조합이다"라고 기록한다.

## 루트 커밋이 필요한 경우

- 프론트엔드 submodule 포인터를 갱신했을 때
- 백엔드 submodule 포인터를 갱신했을 때
- 루트 README, 문서, 공통 설정을 수정했을 때
- 특정 프론트/백엔드 조합을 검증된 상태로 남기고 싶을 때
- 배포나 릴리스 기준 조합을 고정해야 할 때

## 루트 커밋이 꼭 필요하지 않은 경우

- 프론트엔드만 독립적으로 작업하고 해당 저장소에만 반영할 때
- 백엔드만 독립적으로 작업하고 해당 저장소에만 반영할 때
- 루트에서 현재 조합을 고정할 필요가 없을 때

다만 이 경우 루트 저장소는 최신 작업 조합을 알지 못한다.

## 초기 구성 예시

```bash
cd /Users/lickelon/Documents/Projects/dionomy
git init

git submodule add git@github.com:USER/dionomy-frontend.git frontend
git submodule add git@github.com:USER/dionomy-backend.git backend

git add README.md docs .gitmodules frontend backend
git commit -m "Initialize project workspace"
git remote add origin git@github.com:USER/dionomy.git
git push -u origin main
```

`USER`는 실제 GitHub 계정 또는 조직명으로 바꾼다.

## 일반 작업 흐름

프론트엔드 수정:

```bash
cd frontend
git add .
git commit -m "Add frontend feature"
git push

cd ..
git add frontend
git commit -m "Update frontend reference"
git push
```

백엔드 수정:

```bash
cd backend
git add .
git commit -m "Add backend feature"
git push

cd ..
git add backend
git commit -m "Update backend reference"
git push
```

프론트엔드와 백엔드를 함께 검증한 뒤 조합을 고정할 때:

```bash
cd frontend
git add .
git commit -m "Update frontend"
git push

cd ../backend
git add .
git commit -m "Update backend"
git push

cd ..
git add frontend backend
git commit -m "Update app stack references"
git push
```

## 클론 방법

처음부터 submodule까지 함께 받기:

```bash
git clone --recurse-submodules git@github.com:USER/dionomy.git
```

이미 루트만 clone한 경우:

```bash
git submodule update --init --recursive
```

## 운영 원칙

- 루트 저장소는 전체 프로젝트의 기준 조합과 문서를 관리한다.
- 프론트엔드와 백엔드 코드는 각각의 저장소에서 커밋하고 푸시한다.
- 검증된 전체 조합을 남기고 싶을 때 루트에서 submodule 포인터를 커밋한다.
- 루트 저장소에 프론트/백엔드 파일을 직접 복사해서 중복 관리하지 않는다.
- submodule 구조가 번거로워도, 루트까지 GitHub에서 관리하려면 이 방식이 가장 명확하다.
