#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ -n "${CONTAINER_ENGINE:-}" ]]; then
  COMPOSE="${CONTAINER_ENGINE} compose"
elif command -v docker >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v podman >/dev/null 2>&1; then
  COMPOSE="podman compose"
else
  echo "No container engine found. Install Docker or Podman first." >&2
  echo "See modules/module-00-setup/README.md." >&2
  exit 1
fi

export COMPOSE
make m06

cat <<'EOF'

Enterprise estate is up.

  Web (direct):  use `make console`, then `curl http://web/`
  TLS proxy:     https://localhost:8443   (self-signed, expect a warning)
  HTTP proxy:    http://localhost:8080    (redirects to HTTPS)

Next:
  make status
  make console
  follow modules/module-06-web-tls/LAB-GUIDE.md

Stop:
  make down
EOF
