#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
node_version="${NODE_VERSION:-14.21.3}"

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  echo "nvm not found at $HOME/.nvm/nvm.sh" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$HOME/.nvm/nvm.sh"

if ! nvm ls "$node_version" | grep -q "$node_version"; then
  echo "Node $node_version is not installed. Install it first:" >&2
  echo "  nvm install $node_version" >&2
  exit 1
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
  nvm exec "$node_version" npm install
fi

nvm exec "$node_version" npm run dev -- --host "$HOST" --port "$PORT"
