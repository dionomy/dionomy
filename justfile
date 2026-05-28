set shell := ["zsh", "-cu"]

default:
    @just --list

dev:
    #!/usr/bin/env zsh
    set -e
    set -a
    source .env
    set +a
    trap 'for pid in $(jobs -p); do kill "$pid" 2>/dev/null || true; done' INT TERM EXIT
    just db-up
    just db-wait
    (cd backend && just dev) &
    (cd frontend && just dev) &
    wait

db-up:
    set -a; source .env; set +a; docker compose up -d postgres

db-wait:
    #!/usr/bin/env zsh
    set -e
    set -a
    source .env
    set +a
    for _ in {1..30}; do
      if docker compose exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
        exit 0
      fi
      sleep 1
    done
    echo "PostgreSQL is not ready"
    exit 1

db-down:
    docker compose down

db-reset:
    set -a; source .env; set +a; docker compose down -v
    set -a; source .env; set +a; docker compose up -d postgres

frontend-dev:
    cd frontend && just dev

backend-dev:
    cd backend && just dev

build:
    cd frontend && just build

test:
    cd frontend && just test
    cd backend && just test
