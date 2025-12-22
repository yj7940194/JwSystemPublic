#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"

cd "$project_dir"

mode="serve"
case "${1:-}" in
  ""|"--serve")
    mode="serve"
    ;;
  "--install-only")
    mode="install"
    ;;
  *)
    echo "Usage: $(basename "$0") [--serve|--install-only]" >&2
    exit 2
    ;;
esac

node_ver="$(node -v 2>/dev/null || true)"
npm_ver="$(npm -v 2>/dev/null || true)"

lockfile_version=""
if [[ -f package-lock.json ]]; then
  lockfile_version="$(node -p "require('./package-lock.json').lockfileVersion" 2>/dev/null || true)"
fi

echo "Node: ${node_ver:-unknown}"
echo "npm:  ${npm_ver:-unknown}"
echo "Lockfile: ${lockfile_version:-unknown}"

# package-lock.json uses lockfileVersion=3, which requires npm 9+.
if [[ "$lockfile_version" == "3" ]] && [[ -n "${npm_ver:-}" ]]; then
  npm_major="${npm_ver%%.*}"
  if [[ "$npm_major" =~ ^[0-9]+$ ]] && (( npm_major < 9 )); then
    echo "Upgrading npm to v9 (required for lockfileVersion=3)..." >&2
    npm install -g npm@9
    npm_ver="$(npm -v 2>/dev/null || true)"
    echo "npm:  ${npm_ver:-unknown}"
  fi
fi

node_major="$(node -p "parseInt(process.versions.node.split('.')[0], 10)" 2>/dev/null || echo 0)"
node_options=(--max-old-space-size=2048)
# Webpack 4 uses legacy crypto algorithms that are disabled by default in OpenSSL 3 (Node 17+).
if [[ "$node_major" =~ ^[0-9]+$ ]] && (( node_major >= 17 )); then
  node_options+=(--openssl-legacy-provider)
fi
# Some environments deny netlink access, causing os.networkInterfaces() to throw.
node_options+=(--require "$project_dir/scripts/patch-os-networkInterfaces.js")
export NODE_OPTIONS="${NODE_OPTIONS:-} ${node_options[*]}"
echo "NODE_OPTIONS: $NODE_OPTIONS"

lock_hash=""
pkg_hash=""
if [[ -f package-lock.json ]]; then
  lock_hash="$(sha256sum package-lock.json | awk '{print $1}')"
fi
if [[ -f package.json ]]; then
  pkg_hash="$(sha256sum package.json | awk '{print $1}')"
fi
fingerprint="node=${node_ver};npm=${npm_ver};lock=${lock_hash};pkg=${pkg_hash}"
stamp_file="node_modules/.jw_deps_fingerprint"

need_install=false
if [[ ! -d node_modules ]] || [[ -z "$(ls -A node_modules 2>/dev/null)" ]]; then
  need_install=true
elif [[ ! -f "$stamp_file" ]]; then
  need_install=true
elif [[ "$(cat "$stamp_file" 2>/dev/null || true)" != "$fingerprint" ]]; then
  need_install=true
fi

if $need_install; then
  install_cmd=(npm ci --no-audit --no-fund)
  if [[ ! -f package-lock.json ]]; then
    install_cmd=(npm install --no-audit --no-fund --no-package-lock)
  fi

  echo "Installing frontend deps (${install_cmd[*]})..." >&2
  "${install_cmd[@]}"
  mkdir -p node_modules
  echo "$fingerprint" > "$stamp_file"
else
  echo "Frontend deps match lockfile/toolchain; skip install."
fi

if [[ "$mode" == "install" ]]; then
  exit 0
fi

host="${HOST:-0.0.0.0}"
port="${PORT:-8081}"
exec npm run dev -- --host "$host" --port "$port"
