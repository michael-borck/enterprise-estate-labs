#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

cp estate/dns/hosts.broken estate/dns/hosts
docker compose --profile m05 restart dns >/dev/null

echo "DNS fault applied: portal.estate.local now points at 172.28.0.99."
echo "Query it with: ./start.sh exec tools dig @dns portal.estate.local +short"
