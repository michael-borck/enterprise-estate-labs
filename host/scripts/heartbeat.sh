#!/usr/bin/env bash
set -eu

while true; do
  printf '%s heartbeat ok\n' "$(date -Iseconds)"
  sleep "${HEARTBEAT_INTERVAL:-5}"
done
