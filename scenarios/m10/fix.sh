#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

cp estate/backup/backup.good.sh estate/backup/backup.sh

echo "Backup restored: the dump now includes the data."
echo "Run a backup with: ./start.sh exec backup sh /backup/backup.sh"
