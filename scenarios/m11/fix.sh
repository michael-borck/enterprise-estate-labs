#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

rm -f estate/web/admin/config.txt

new_password="Rotated-$(date +%s)"
./start.sh exec logs sh -c "printf '%s\n' '$new_password' > /logs/db_password && chmod 600 /logs/db_password"
./start.sh restart web >/dev/null

echo "Exposure closed: /admin/config.txt has been removed."
echo "Secret rotated and restricted to mode 600."
echo "The database credential must also be rotated wherever it is used."
