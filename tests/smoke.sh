#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

ENGINE="${CONTAINER_ENGINE:-}"
if [[ -z "$ENGINE" ]]; then
  if command -v docker >/dev/null 2>&1; then
    ENGINE="docker"
  elif command -v podman >/dev/null 2>&1; then
    ENGINE="podman"
  else
    echo "No container runtime found." >&2
    exit 1
  fi
fi

if [[ -z "${COMPOSE:-}" ]]; then
  if [[ "$ENGINE" == "podman" ]]; then
    if podman compose version >/dev/null 2>&1; then
      COMPOSE="podman compose"
    else
      COMPOSE="podman-compose"
    fi
  else
    COMPOSE="docker compose"
  fi
fi

cleanup() {
  $COMPOSE --profile m03 --profile m05 --profile m06 --profile m09 down -v --remove-orphans >/dev/null 2>&1 || true
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

echo "==> Module 05: internal DNS"
$COMPOSE --profile m03 --profile m05 up -d
wait_for "DNS" $COMPOSE --profile m03 --profile m05 exec -T tools dig @dns portal.estate.local +short
$COMPOSE --profile m03 --profile m05 exec -T tools dig @dns portal.estate.local +short | grep -q "172.28.0.10"
$COMPOSE --profile m03 --profile m05 exec -T tools curl -fsS --resolve portal.estate.local:80:172.28.0.10 http://portal.estate.local/ | grep -qi "CloudCore estate"

echo "==> Module 06: proxy and TLS"
$COMPOSE --profile m03 --profile m05 --profile m06 up -d
wait_for "TLS proxy" curl -kfsS https://localhost:8443/
curl -kfsS https://localhost:8443/ | grep -qi "CloudCore estate"

echo "==> Module 09: shared volume"
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m09 up -d
$COMPOSE ps

echo "Smoke test passed"
