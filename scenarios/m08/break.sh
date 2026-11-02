#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

./start.sh exec identity delgroup svc-report reporting >/dev/null 2>&1 || true

echo "Identity fault applied: svc-report is no longer a member of the reporting group."
echo "Test it with: ./start.sh exec --user svc-report identity cat /reports/quarterly.txt"
