#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
node_version="${NODE_VERSION:-14.21.3}"

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
    echo "  - or install Node.js >=14" >&2
    exit 1
  fi
fi

cd "$repo_dir/Jwsystem-front"

# Some sandboxed environments deny netlink access, causing Node's os.networkInterfaces()
# to throw (uv_interface_addresses EPERM). Preload a tiny patch to keep dev server alive.
export NODE_OPTIONS="--max-old-space-size=2048 --require $repo_dir/Jwsystem-front/scripts/patch-os-networkInterfaces.js"
echo "NODE_OPTIONS: $NODE_OPTIONS"

# Some environments deny binding to 0.0.0.0; force loopback.
export HOST="${HOST:-127.0.0.1}"
export PORT="${PORT:-8081}"
echo "HOST: $HOST"
echo "PORT: $PORT"

if [[ ! -d node_modules ]]; then
  if $use_nvm; then
    nvm exec "$node_version" npm install
  else
    npm install
  fi
fi

if $use_nvm; then
  nvm exec "$node_version" npm run dev -- --host "$HOST" --port "$PORT"
else
  npm run dev -- --host "$HOST" --port "$PORT"
fi
