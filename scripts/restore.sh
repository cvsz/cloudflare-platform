#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
trap 'echo "{\"level\":\"error\",\"script\":\"restore\",\"line\":$LINENO}"' ERR

archive="${1:?usage: restore.sh <backup-tar.gz>}"
checksum_file="${archive}.sha256"
[[ -f "$archive" ]]
[[ -f "$checksum_file" ]]
sha256sum -c "$checksum_file"

tar -xzf "$archive"
echo "restore_completed=${archive}"
