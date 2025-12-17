#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

backend_pid_file="$repo_dir/backend-dev.pid"
frontend_pid_file="$repo_dir/frontend.pid"

backend_log="$repo_dir/backend-dev.log"
frontend_log="$repo_dir/frontend_run.log"

have_setsid() { command -v setsid >/dev/null 2>&1; }

is_running_pid() {
  local pid="$1"
  [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1
}

read_pid_file() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  tr -d '[:space:]' <"$file" | head -c 32
}

start_bg() {
  local cmd="$1"
  local log="$2"
  local pid_file="$3"

  if [[ -f "$pid_file" ]]; then
    local old_pid
    old_pid="$(read_pid_file "$pid_file" || true)"
    if [[ -n "$old_pid" ]] && is_running_pid "$old_pid"; then
      echo "Already running (pid=$old_pid): $pid_file"
      return 0
    fi
    rm -f "$pid_file"
  fi

  mkdir -p "$(dirname "$log")"
  : >>"$log"

  if have_setsid; then
    # Start in a new session so we can stop by killing the process group.
    setsid bash -lc "$cmd" >>"$log" 2>&1 < /dev/null &
  else
    nohup bash -lc "$cmd" >>"$log" 2>&1 < /dev/null &
  fi

  echo $! >"$pid_file"
  echo "Started (pid=$(cat "$pid_file")): $cmd"
}

wait_http() {
  local url="$1"
  local label="$2"
  local max_seconds="${3:-120}"

  for i in $(seq 1 "$max_seconds"); do
    local code
    code="$(curl -s -o /dev/null -w "%{http_code}" "$url" || true)"
    if [[ "$code" != "000" ]]; then
      echo "$label reachable after ${i}s (http_code=$code): $url"
      return 0
    fi
    sleep 1
  done

  echo "$label not reachable after ${max_seconds}s: $url" >&2
  return 1
}

echo "Repo: $repo_dir"

start_bg "$repo_dir/run-backend-dev.sh" "$backend_log" "$backend_pid_file"
wait_http "http://127.0.0.1:8080/" "Backend" 180

start_bg "$repo_dir/run-frontend-dev.sh" "$frontend_log" "$frontend_pid_file"
wait_http "http://127.0.0.1:8081/" "Frontend" 120

echo "OK"
echo "Backend:  http://127.0.0.1:8080/"
echo "Frontend: http://127.0.0.1:8081/"

