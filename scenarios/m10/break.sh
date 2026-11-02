#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

cp estate/backup/backup.broken.sh estate/backup/backup.sh

echo "Backup fault applied: the dump now contains the schema only."
echo "Run a backup with: ./start.sh exec backup sh /backup/backup.sh"
