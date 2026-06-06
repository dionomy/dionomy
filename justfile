set shell := ["zsh", "-cu"]

default:
    @just --list

doctor:
    ./scripts/doctor.sh

setup:
    ./scripts/setup.sh

dev:
    ./scripts/dev.sh

seed:
    ./scripts/seed-dev-data.sh

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

deploy-build:
    set -a; source .env; set +a; docker compose -f docker-compose.prod.yml build backend frontend

deploy-up:
    set -a; source .env; set +a; docker compose -f docker-compose.prod.yml up -d

deploy-down:
    set -a; source .env; set +a; docker compose -f docker-compose.prod.yml down

deploy-logs:
    docker compose -f docker-compose.prod.yml logs -f --tail=200
