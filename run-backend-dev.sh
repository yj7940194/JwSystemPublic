#!/usr/bin/env bash
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Repo: $repo_dir"

if [[ -f "$repo_dir/.env.local" ]]; then
    echo "Sourcing .env.local..."
    source "$repo_dir/.env.local"
    echo "Loaded JW_DB_URL: $JW_DB_URL"
    export JW_DB_URL
    export JW_DB_USER
    export JW_DB_PASSWORD
else
    echo "No .env.local found!"
fi

if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  set +u
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  # set -u
  sdk use java 8.0.472-tem >/dev/null 2>&1 || true
fi

if [[ -z "${JAVA_HOME:-}" ]]; then
  if [[ -d "$HOME/.sdkman/candidates/java/current" ]]; then
    export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
  elif [[ -d "$HOME/.sdkman/candidates/java/8.0.472-tem" ]]; then
    export JAVA_HOME="$HOME/.sdkman/candidates/java/8.0.472-tem"
  fi
fi

if [[ -n "${JAVA_HOME:-}" ]]; then
  export PATH="$JAVA_HOME/bin:$PATH"
fi

cd "$repo_dir/Jwsystem"

echo "Executing Maven with URL: $JW_DB_URL"

mvn -DskipTests \
  -DJW_DB_URL="$JW_DB_URL" \
  -DJW_DB_USER="$JW_DB_USER" \
  -DJW_DB_PASSWORD="$JW_DB_PASSWORD" \
  spring-boot:run
