#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
trap 'echo "{\"level\":\"error\",\"script\":\"backup\",\"line\":$LINENO}"' ERR

: "${BACKUP_DIR:=backups/snapshots}"
: "${ENVIRONMENT:=dev}"
mkdir -p "$BACKUP_DIR"
ts="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$BACKUP_DIR/${ENVIRONMENT}-${ts}.tar.gz"

tar --exclude='.git' -czf "$archive" terraform opentofu zero-trust waf dns tunnels policies monitoring security docs scripts
sha256sum "$archive" > "${archive}.sha256"
echo "backup_created=${archive}"
