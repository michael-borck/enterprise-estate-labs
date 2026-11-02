#!/bin/sh
set -eu

add_group() {
  getent group "$1" >/dev/null 2>&1 || addgroup -g "$2" "$1"
}

add_user() {
  getent passwd "$1" >/dev/null 2>&1 || adduser -D -u "$2" -G "$3" -s "$4" "$1"
}

add_group ops 2000
add_group finance 2001
add_group reporting 2002
add_group contractors 2003
add_group services 2004

add_user alice 2000 ops /bin/sh
add_user bob 2001 finance /bin/sh
add_user svc-report 2002 services /sbin/nologin
add_user contractor 2003 contractors /bin/sh

while IFS=: read -r group members; do
  [ -n "${group:-}" ] || continue
  case "$group" in
    \#*) continue ;;
  esac
  for user in $(printf '%s' "$members" | tr ',' ' '); do
    [ -n "$user" ] || continue
    addgroup "$user" "$group" 2>/dev/null || true
  done
done < /etc/identity/membership

mkdir -p /reports
cat > /reports/quarterly.txt <<'EOF'
CloudCore Networks
Finance report: Q1
Status: draft
Prepared by: Finance Systems
EOF

cat > /reports/board-pack.txt <<'EOF'
CloudCore Networks
Board pack: Q1
Status: confidential
Distribution: Finance Systems only
EOF

chown root:reporting /reports
chmod 750 /reports
chown bob:reporting /reports/quarterly.txt
chmod 640 /reports/quarterly.txt
chown bob:finance /reports/board-pack.txt
chmod 640 /reports/board-pack.txt

exec sleep infinity
