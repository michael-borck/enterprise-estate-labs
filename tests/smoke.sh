#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

COMPOSE="${COMPOSE:-docker compose}"

cleanup() {
  $COMPOSE --profile m03 --profile m06 --profile m09 down -v --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup EXIT

wait_for() {
  local description="$1"
  shift
  for _ in $(seq 1 30); do
    if "$@" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Timed out waiting for ${description}" >&2
  return 1
}

echo "==> Validating compose file"
$COMPOSE config >/dev/null

echo "==> Module 03: web, db and tools"
$COMPOSE --profile m03 up -d
wait_for "web" $COMPOSE --profile m03 exec -T tools curl -fsS http://web/
$COMPOSE --profile m03 exec -T tools curl -fsS http://web/ | grep -qi "CloudCore estate"

echo "==> Module 06: proxy and TLS"
$COMPOSE --profile m03 --profile m06 up -d
wait_for "TLS proxy" curl -kfsS https://localhost:8443/
curl -kfsS https://localhost:8443/ | grep -qi "CloudCore estate"

echo "==> Module 09: shared volume"
$COMPOSE --profile m03 --profile m06 --profile m09 up -d
$COMPOSE ps

echo "Smoke test passed"
