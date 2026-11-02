#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

cp estate/dns/hosts.good estate/dns/hosts
docker compose --profile m05 restart dns >/dev/null

echo "DNS restored: portal.estate.local points at 172.28.0.10."
