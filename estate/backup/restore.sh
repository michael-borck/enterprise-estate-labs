#!/bin/sh
set -eu

psql -h db -U estate -d postgres -c 'DROP DATABASE IF EXISTS estate_restore;' >/dev/null
psql -h db -U estate -d postgres -c 'CREATE DATABASE estate_restore;' >/dev/null
psql -h db -U estate -d estate_restore < /backups/estate.sql >/dev/null

estate_count=$(psql -h db -U estate -d estate -tAc 'SELECT count(*) FROM tickets;')
restore_count=$(psql -h db -U estate -d estate_restore -tAc 'SELECT count(*) FROM tickets;' 2>/dev/null || echo 'table missing')

echo "tickets in estate:          ${estate_count}"
echo "tickets in estate_restore:  ${restore_count}"
