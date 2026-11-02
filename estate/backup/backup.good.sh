#!/bin/sh
set -eu

pg_dump -h db -U estate -d estate > /backups/estate.sql
echo "$(date -Iseconds) backup complete" >> /backups/backup.log
