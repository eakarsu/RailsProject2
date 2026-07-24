#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir"
set -a
# shellcheck disable=SC1091
source .env
set +a

if [ -x /opt/homebrew/opt/ruby/bin/ruby ]; then
  export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
fi
if ! command -v ruby >/dev/null 2>&1 || ! command -v bundle >/dev/null 2>&1; then
  printf 'Ruby 3.2 or newer and Bundler are required.\n' >&2
  exit 1
fi
if ! ruby -e 'exit((RUBY_VERSION.split(".").first(2).map(&:to_i) <=> [3, 2]) >= 0 ? 0 : 1)'; then
  printf 'Ruby 3.2 or newer is required.\n' >&2
  exit 1
fi
if ! bundle check >/dev/null 2>&1; then
  printf 'Bundle is incomplete; run bundle install before startup.\n' >&2
  exit 1
fi

api_port="${BACKEND_PORT:-${PORT:-3000}}"
ui_port="${FRONTEND_PORT:-3001}"
for runtime_port in "$api_port" "$ui_port"; do
  if [[ ! "$runtime_port" =~ ^[0-9]+$ ]] || [ "$runtime_port" -lt 1 ] || [ "$runtime_port" -gt 65535 ]; then
    printf 'Runtime ports must be integers between 1 and 65535.\n' >&2
    exit 1
  fi
  if lsof -tiTCP:"$runtime_port" -sTCP:LISTEN >/dev/null 2>&1; then printf 'Port %s is occupied.\n' "$runtime_port" >&2; exit 1; fi
done

if [ "${NODE_ENV:-development}" = production ]; then runtime_environment=production; else runtime_environment=test; fi
export RAILS_ENV="$runtime_environment"

case "${MIGRATE_ON_START:-0}" in
1|true)
  bundle exec rails db:prepare
  ;;
esac
if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
  BOOTSTRAP_ADMIN_EMAIL="$ADMIN_EMAIL" \
    BOOTSTRAP_ADMIN_PASSWORD="$ADMIN_PASSWORD" \
    bundle exec rails db:seed
fi

PORT="$api_port" PIDFILE="/private/tmp/railsproject2-api-$$.pid" ./bin/start & api_pid=$!
trap 'kill "${api_pid:-}" "${ui_pid:-}" 2>/dev/null || true; wait "${api_pid:-}" "${ui_pid:-}" 2>/dev/null || true' INT TERM EXIT
for attempt in {1..240}; do curl --max-time 2 -fsS "http://127.0.0.1:$api_port/health" >/dev/null 2>&1 && break; kill -0 "$api_pid" 2>/dev/null||{ wait "$api_pid"||true; printf 'API exited before startup.\n' >&2; exit 1; }; sleep 0.25; done
curl --max-time 5 -fsS "http://127.0.0.1:$api_port/health" >/dev/null||{ printf 'API did not become ready.\n' >&2; exit 1; }
PORT="$ui_port" PIDFILE="/private/tmp/railsproject2-ui-$$.pid" ./bin/start & ui_pid=$!
wait "$api_pid" "$ui_pid"
