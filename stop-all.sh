#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

backend_pid_file="$repo_dir/backend-dev.pid"
frontend_pid_file="$repo_dir/frontend.pid"

is_running_pid() {
  local pid="$1"
  [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1
}

read_pid_file() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  tr -d '[:space:]' <"$file" | head -c 32
}

pid_cmdline() {
  local pid="$1"
  ps -p "$pid" -o cmd= 2>/dev/null || true
}

stop_by_pidfile() {
  local pid_file="$1"
  local expected_substr="$2"

  if [[ ! -f "$pid_file" ]]; then
    echo "No pid file: $pid_file"
    return 0
  fi

  local pid
  pid="$(read_pid_file "$pid_file" || true)"
  if [[ -z "$pid" ]]; then
    rm -f "$pid_file"
    echo "Removed empty pid file: $pid_file"
    return 0
  fi

  if ! is_running_pid "$pid"; then
    rm -f "$pid_file"
    echo "Not running (stale pid=$pid). Removed: $pid_file"
    return 0
  fi

  local cmd
  cmd="$(pid_cmdline "$pid")"
  if [[ -n "$expected_substr" ]] && [[ "$cmd" != *"$expected_substr"* ]]; then
    echo "Refusing to kill pid=$pid (cmd='$cmd') because it doesn't match '$expected_substr'." >&2
    echo "If you really want to kill it, remove $pid_file and stop it manually." >&2
    return 1
  fi

  echo "Stopping pid=$pid (cmd='$cmd')"

  # Prefer killing the process group (works best if started with setsid).
  kill -TERM -- "-$pid" >/dev/null 2>&1 || kill -TERM "$pid" >/dev/null 2>&1 || true

  for _ in $(seq 1 20); do
    if ! is_running_pid "$pid"; then
      rm -f "$pid_file"
      echo "Stopped. Removed: $pid_file"
      return 0
    fi
    sleep 0.5
  done

  echo "Still running after 10s; sending SIGKILL pid=$pid" >&2
  kill -KILL -- "-$pid" >/dev/null 2>&1 || kill -KILL "$pid" >/dev/null 2>&1 || true
  rm -f "$pid_file"
  echo "Killed. Removed: $pid_file"
}

echo "Repo: $repo_dir"
stop_by_pidfile "$frontend_pid_file" "run-frontend-dev.sh"
stop_by_pidfile "$backend_pid_file" "run-backend-dev.sh"
echo "OK"

