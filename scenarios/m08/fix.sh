#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

./start.sh exec identity addgroup svc-report reporting

echo "Identity restored: svc-report is back in the reporting group."
echo "Verify with: ./start.sh exec --user svc-report identity cat /reports/quarterly.txt"
