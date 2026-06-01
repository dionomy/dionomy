#!/usr/bin/env zsh
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  print "[ok] .env 생성"
else
  print "[ok] .env 존재"
fi

set -a
source .env
set +a

if [[ ! -d frontend/node_modules ]]; then
  if [[ -f frontend/package-lock.json ]]; then
    print "[run] cd frontend && npm ci"
    (cd frontend && npm ci)
  else
    print "[run] cd frontend && npm install"
    (cd frontend && npm install)
  fi
else
  print "[ok] frontend/node_modules 존재"
fi

print "[run] docker compose up -d postgres"
docker compose up -d postgres

print "[run] just db-wait"
just db-wait

print "[run] just doctor"
just doctor
