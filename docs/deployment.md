# 배포 가이드

Dionomy 배포는 Docker 이미지 기반으로 한다.

배포 서버에 필요한 것:

- Docker
- Docker Compose

배포 서버에 없어도 되는 것:

- Java
- Gradle
- Node.js
- npm

## 구성

```txt
frontend  Nginx + Vite 정적 파일
backend   Spring Boot jar + JRE 21
postgres  PostgreSQL 16
```

배포 compose:

```bash
docker-compose.prod.yml
```

## 서버 최초 설정

```bash
cp .env.deploy.example .env
```

`.env`에서 최소한 `POSTGRES_PASSWORD`는 운영용 값으로 변경한다.

## 빌드

```bash
just deploy-build
```

## 실행

```bash
just deploy-up
```

기본 접속 포트는 `80`이다. 변경하려면 `.env`의 `DIONOMY_HTTP_PORT`를 수정한다.

## 로그

```bash
just deploy-logs
```

## 종료

```bash
just deploy-down
```

## 라우팅

프론트 Nginx가 다음 요청을 백엔드로 프록시한다.

```txt
/api/*
/health
/actuator/*
```

나머지 경로는 SPA 라우팅을 위해 `index.html`로 반환한다.
