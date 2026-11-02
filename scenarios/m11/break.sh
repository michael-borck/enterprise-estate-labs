#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p estate/web/admin
cat > estate/web/admin/config.txt <<'EOF'
DB_PASSWORD=estate-demo
ADMIN_TOKEN=cloudcore-admin-2026
EOF
chmod 644 estate/web/admin/config.txt

./start.sh exec logs sh -c "printf 'estate-demo\n' > /logs/db_password && chmod 644 /logs/db_password"
./start.sh restart web >/dev/null

echo "Exposure reintroduced: /admin/config.txt is readable."
echo "The database secret is world-readable and still set to the demo value."
