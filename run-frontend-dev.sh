#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
node_version="${NODE_VERSION:-16.20.2}"

use_nvm=false
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.nvm/nvm.sh"
  if nvm ls "$node_version" | grep -q "$node_version"; then
    use_nvm=true
  else
    echo "Node $node_version is not installed in nvm. Falling back to system node (if available)." >&2
  fi
fi

if ! $use_nvm; then
  if ! command -v node >/dev/null 2>&1; then
    echo "Neither nvm($node_version) nor system node found. Install one of them:" >&2
    echo "  - nvm install $node_version" >&2
    echo "  - or install Node.js >=16" >&2
    exit 1
  fi
fi

run_node() {
  if $use_nvm; then
    nvm exec --silent "$node_version" node "$@"
  else
    node "$@"
  fi
}

run_npm() {
  if $use_nvm; then
    nvm exec --silent "$node_version" npm "$@"
  else
    npm "$@"
  fi
}

cd "$repo_dir/Jwsystem-front"

# Ensure the toolchain can actually consume our lockfile.
# (package-lock.json uses lockfileVersion=3 → requires npm 9+)
lockfile_version=""
if [[ -f package-lock.json ]]; then
  lockfile_version="$(run_node -p "require('./package-lock.json').lockfileVersion" 2>/dev/null || true)"
fi

node_ver="$(run_node -v 2>/dev/null || true)"
npm_ver="$(run_npm -v 2>/dev/null || true)"
echo "Node: ${node_ver:-unknown}"
echo "npm:  ${npm_ver:-unknown}"
echo "Lockfile: ${lockfile_version:-unknown}"

if [[ "$lockfile_version" == "3" ]] && [[ -n "${npm_ver:-}" ]]; then
  npm_major="${npm_ver%%.*}"
  if [[ "$npm_major" =~ ^[0-9]+$ ]] && (( npm_major < 9 )); then
    echo "Upgrading npm to v9 (required for lockfileVersion=3)..." >&2
    run_npm install -g npm@9
    npm_ver="$(run_npm -v 2>/dev/null || true)"
    echo "npm:  ${npm_ver:-unknown}"
  fi
fi

# Avoid silent port bump (which breaks start-all.sh's health check).
if command -v ss >/dev/null 2>&1; then
  if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE "[:\\]]${PORT:-8081}$"; then
    echo "Port ${PORT:-8081} is already in use. Stop the process or set PORT to a free port." >&2
    exit 1
  fi
fi

# Some sandboxed environments deny netlink access, causing Node's os.networkInterfaces()
# to throw (uv_interface_addresses EPERM). Preload a tiny patch to keep dev server alive.
node_major="$(run_node -p "parseInt(process.versions.node.split('.')[0], 10)" 2>/dev/null || echo 0)"
node_options=(--max-old-space-size=2048)
# Webpack 4 uses legacy crypto algorithms that are disabled by default in OpenSSL 3 (Node 17+).
if [[ "$node_major" =~ ^[0-9]+$ ]] && (( node_major >= 17 )); then
  node_options+=(--openssl-legacy-provider)
fi
node_options+=(--require "$repo_dir/Jwsystem-front/scripts/patch-os-networkInterfaces.js")
export NODE_OPTIONS="${node_options[*]}"
echo "NODE_OPTIONS: $NODE_OPTIONS"

# Some environments deny binding to 0.0.0.0; force loopback.
export HOST="${HOST:-127.0.0.1}"
export PORT="${PORT:-8081}"
echo "HOST: $HOST"
echo "PORT: $PORT"

if [[ ! -d node_modules ]]; then
  # npm ci is deterministic and respects package-lock.json.
  if [[ -f package-lock.json ]]; then
    run_npm ci
  else
    run_npm install
  fi
fi

run_npm run dev -- --host "$HOST" --port "$PORT"
