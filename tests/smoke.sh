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
  $COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 down -v --remove-orphans >/dev/null 2>&1 || true
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

echo "==> Cleaning any previous estate"
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 down -v --remove-orphans >/dev/null 2>&1 || true

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

echo "==> Module 08: identity and access"
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 up -d
wait_for "identity" $COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T identity getent group reporting
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T identity getent group reporting | grep -q "svc-report"
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T --user bob identity cat /reports/quarterly.txt | grep -qi "CloudCore"
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T --user bob identity cat /reports/board-pack.txt | grep -qi "confidential"
if $COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T --user contractor identity cat /reports/quarterly.txt >/dev/null 2>&1; then
  echo "contractor should not be able to read the quarterly report" >&2
  exit 1
fi
if $COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T --user contractor identity cat /reports/board-pack.txt >/dev/null 2>&1; then
  echo "contractor should not be able to read the board pack" >&2
  exit 1
fi
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T --user alice identity sudo -n id >/dev/null
if $COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 exec -T --user alice identity sudo -n cat /reports/quarterly.txt >/dev/null 2>&1; then
  echo "alice should not be able to sudo cat the report" >&2
  exit 1
fi

echo "==> Module 09: shared volume"
$COMPOSE --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 up -d
$COMPOSE ps

echo "Smoke test passed"
