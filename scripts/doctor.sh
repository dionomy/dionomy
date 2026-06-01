#!/usr/bin/env zsh
set +e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

fail_count=0
warn_count=0
actions=()

ok() {
  print "[ok] $1"
}

warn() {
  warn_count=$((warn_count + 1))
  print "[warn] $1"
}

fail() {
  fail_count=$((fail_count + 1))
  print "[fail] $1"
}

add_action() {
  for action in "${actions[@]}"; do
    if [[ "$action" == "$1" ]]; then
      return
    fi
  done

  actions+=("$1")
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

check_command() {
  if has_command "$1"; then
    ok "$1 사용 가능"
  else
    fail "$1 없음"
    add_action "$1 설치 필요"
  fi
}

print "Dionomy doctor"
print ""

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
  ok ".env 존재"
else
  fail ".env 없음"
  add_action "cp .env.example .env 후 값 설정"
fi

print ""
print "필수 도구"
check_command just
check_command docker
if has_command docker && docker compose version >/dev/null 2>&1; then
  ok "docker compose 사용 가능"
else
  fail "docker compose 사용 불가"
  add_action "Docker Compose 플러그인 확인"
fi
check_command node
check_command npm

print ""
print "Java"
if [[ -n "$JAVA_HOME" ]]; then
  if [[ -x "$JAVA_HOME/bin/java" ]]; then
    java_cmd="$JAVA_HOME/bin/java"
    ok "JAVA_HOME 사용: $JAVA_HOME"
  else
    java_cmd=""
    fail "JAVA_HOME이 유효하지 않음: $JAVA_HOME"
    add_action ".env의 JAVA_HOME을 실제 JDK 경로로 수정"
  fi
else
  java_cmd="$(command -v java 2>/dev/null)"
  if [[ -n "$java_cmd" ]]; then
    ok "PATH java 사용: $java_cmd"
  else
    fail "Java 없음"
    add_action "Java 21 설치 또는 .env JAVA_HOME 설정"
  fi
fi

if [[ -n "$java_cmd" ]]; then
  java_version="$("$java_cmd" -version 2>&1 | head -n 1)"
  if [[ "$java_version" == *\"21* ]]; then
    ok "Java 21 확인: $java_version"
  else
    fail "Java 21 아님: $java_version"
    add_action "Java 21을 PATH 또는 .env JAVA_HOME에 설정"
  fi
fi

print ""
print "환경 변수"
required_env=(
  POSTGRES_DB
  POSTGRES_USER
  POSTGRES_PASSWORD
  DIONOMY_DATABASE_URL
  DIONOMY_DATABASE_USERNAME
  DIONOMY_DATABASE_PASSWORD
)

for key in "${required_env[@]}"; do
  if [[ -n "${(P)key}" ]]; then
    ok "$key 설정됨"
  else
    fail "$key 누락"
    add_action ".env에 $key 설정"
  fi
done

if [[ -n "$POSTGRES_PASSWORD" && -n "$DIONOMY_DATABASE_PASSWORD" ]]; then
  if [[ "$POSTGRES_PASSWORD" == "$DIONOMY_DATABASE_PASSWORD" ]]; then
    ok "DB 비밀번호 env 일치"
  else
    fail "POSTGRES_PASSWORD와 DIONOMY_DATABASE_PASSWORD 불일치"
    add_action "두 비밀번호를 맞춘 뒤 필요하면 just db-reset"
  fi
fi

if [[ "$DIONOMY_DATABASE_URL" == *":5432/"* ]]; then
  ok "DB URL 포트 5432"
else
  warn "DB URL 포트 확인 필요: $DIONOMY_DATABASE_URL"
  add_action ".env의 DIONOMY_DATABASE_URL 포트 확인"
fi

print ""
print "Docker DB"
if has_command docker && docker compose ps postgres >/dev/null 2>&1; then
  postgres_status="$(docker compose ps postgres 2>/dev/null)"
  if [[ "$postgres_status" == *"running"* || "$postgres_status" == *"Up"* ]]; then
    ok "postgres 컨테이너 실행 중"
  else
    warn "postgres 컨테이너가 실행 중이 아님"
    add_action "just db-up"
  fi

  if docker compose exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
    ok "Postgres readiness 통과"
  else
    warn "Postgres readiness 실패"
    add_action "just db-up 후 just db-wait"
  fi
else
  warn "Docker compose postgres 상태 확인 실패"
  add_action "Docker Desktop 실행 후 just db-up"
fi

print ""
print "포트"
for port label in 5173 frontend 8080 backend 5432 postgres 35729 livereload; do
  if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    ok "$label 포트 $port 사용 중"
  else
    warn "$label 포트 $port 미사용"
    case "$label" in
      frontend)
        add_action "just frontend-dev"
        ;;
      backend)
        add_action "just backend-dev"
        ;;
      postgres)
        add_action "just db-up"
        ;;
      livereload)
        add_action "백엔드 devtools LiveReload가 필요하면 just backend-dev"
        ;;
    esac
  fi
done

print ""
print "프로젝트 파일"
if [[ -x backend/gradlew ]]; then
  ok "backend/gradlew 실행 가능"
else
  fail "backend/gradlew 실행 불가"
  add_action "chmod +x backend/gradlew"
fi
if [[ -f frontend/package.json ]]; then
  ok "frontend/package.json 존재"
else
  fail "frontend/package.json 없음"
  add_action "frontend 서브모듈 상태 확인"
fi

if [[ -d frontend/node_modules ]]; then
  ok "frontend/node_modules 존재"
else
  warn "frontend/node_modules 없음"
  if [[ -f frontend/package-lock.json ]]; then
    add_action "cd frontend && npm ci"
  else
    add_action "cd frontend && npm install"
  fi
fi

print ""
if (( ${#actions[@]} > 0 )); then
  print "권장 조치"
  for action in "${actions[@]}"; do
    print "- $action"
  done
else
  print "권장 조치 없음"
fi

print ""
if (( fail_count > 0 )); then
  print "결과: fail $fail_count, warn $warn_count"
  exit 1
fi

print "결과: ok, warn $warn_count"
