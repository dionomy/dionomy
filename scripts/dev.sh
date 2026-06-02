#!/usr/bin/env zsh
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

set -a
source .env
set +a

children_of() {
  local parent="$1"
  pgrep -P "$parent" 2>/dev/null || true
}

process_tree() {
  local parent="$1"
  local child

  for child in $(children_of "$parent"); do
    process_tree "$child"
  done

  print "$parent"
}

terminate_tree() {
  local root_pid="$1"
  local pids

  [[ -n "$root_pid" ]] || return
  kill -0 "$root_pid" 2>/dev/null || return

  pids=($(process_tree "$root_pid"))
  if (( ${#pids[@]} > 0 )); then
    kill -TERM "${pids[@]}" 2>/dev/null || true
    sleep 1
    kill -KILL "${pids[@]}" 2>/dev/null || true
  fi
}

cleanup() {
  trap - INT TERM EXIT

  terminate_tree "${backend_pid:-}"
  terminate_tree "${frontend_pid:-}"
}

handle_interrupt() {
  cleanup
  exit 130
}

handle_term() {
  cleanup
  exit 143
}

trap handle_interrupt INT
trap handle_term TERM
trap cleanup EXIT

./scripts/check-dev-ports.sh
just db-up
just db-wait

(cd backend && just dev) &
backend_pid=$!

(cd frontend && just dev) &
frontend_pid=$!

wait "$backend_pid" "$frontend_pid"
