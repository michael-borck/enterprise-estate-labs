#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

fail=0

if ./start.sh exec tools curl -fsS http://web/admin/config.txt >/dev/null 2>&1; then
  echo "FAIL: /admin/config.txt is still reachable"
  fail=1
else
  echo "OK: /admin/config.txt is not reachable"
fi

mode=$(./start.sh exec logs stat -c '%a' /logs/db_password | tr -d '[:space:]')
if [[ "$mode" == "600" ]]; then
  echo "OK: db_password is mode 600"
else
  echo "FAIL: db_password is mode ${mode:-unknown}"
  fail=1
fi

if ./start.sh exec logs grep -q 'estate-demo' /logs/db_password; then
  echo "FAIL: db_password still contains the demo value"
  fail=1
else
  echo "OK: db_password rotated"
fi

if ./start.sh exec logs grep -q '203.0.113.45' /logs/security.log; then
  echo "OK: incident source found in the security log"
else
  echo "FAIL: incident source missing from the security log"
  fail=1
fi

if [[ $fail -eq 0 ]]; then
  echo "Security check passed"
else
  echo "Security check failed"
fi
exit $fail
