# 배포 가이드

Dionomy는 홈서버의 공통 Nginx/Certbot 뒤에 서비스로 등록해서 배포한다.

배포 서버에 필요한 것:

- Docker
- Docker Compose
- 공통 Nginx

배포 서버에 없어도 되는 것:

- Java
- Gradle
- Node.js
- npm

## 구성

```txt
common nginx  TLS, 도메인 라우팅, 서비스 프록시
frontend      React 정적 파일 서버 컨테이너
backend       Spring Boot jar + JRE 21 컨테이너
postgres      PostgreSQL 16 컨테이너
```

`docker-compose.prod.yml`은 `frontend`, `backend`, `postgres`를 실행한다.

공통 Nginx는 외부 공개를 담당하고, Dionomy 컨테이너는 기본적으로 `127.0.0.1`에만 포트를 연다.

## 서버 최초 설정

```bash
cp .env.deploy.example .env
```

`.env`에서 최소한 `POSTGRES_PASSWORD`는 운영용 값으로 변경한다.

```env
POSTGRES_PASSWORD=change-this-password
DIONOMY_BACKEND_BIND=127.0.0.1
DIONOMY_BACKEND_PORT=18080
DIONOMY_FRONTEND_BIND=127.0.0.1
DIONOMY_FRONTEND_PORT=18081
```

프론트는 `127.0.0.1:${DIONOMY_FRONTEND_PORT}`로 노출한다.
백엔드는 `127.0.0.1:${DIONOMY_BACKEND_PORT}`로 노출한다.

## 빌드

```bash
just deploy-build
```

## 실행

```bash
just deploy-up
```

## 공통 Nginx 등록 예시

```nginx
server {
    listen 80;
    server_name dionomy.example.com;

    location /api/ {
        proxy_pass http://127.0.0.1:18080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://127.0.0.1:18081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

TLS는 기존 Certbot 운영 방식에 맞춰 이 server block에 적용한다.

## 로그

```bash
just deploy-logs
```

## 종료

```bash
just deploy-down
```
