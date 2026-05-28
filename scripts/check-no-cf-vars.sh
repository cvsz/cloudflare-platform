#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${PROJECT_ROOT:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$PWD"
  while [[ "$ROOT" != "/" ]]; do
    if [[ -d "$ROOT/.git" || -f "$ROOT/Makefile" || -f "$ROOT/.env.example" ]]; then
      break
    fi
    ROOT="$(dirname "$ROOT")"
  done
fi
[[ "$ROOT" != "/" ]] || ROOT="$PWD"
cd "$ROOT"

short_prefix="C""F_"
legacy_regex="\\b${short_prefix}(ACCOUNT_ID|ZONE_ID|BOOTSTRAP_TOKEN|DNS_TOKEN|ZT_TOKEN|WORKERS_TOKEN|WAF_TOKEN|TUNNEL_TOKEN|R2_TOKEN|AUDIT_TOKEN|AI_GATEWAY_TOKEN|AI_GATEWAY_SLUG)\\b"

exclude_paths=(
  ':!*.png'
  ':!*.jpg'
  ':!*.jpeg'
  ':!*.gif'
  ':!*.webp'
  ':!*.ico'
  ':!*.pdf'
  ':!*.zip'
  ':!.backup/**'
  ':!.cloudflare-backups/**'
  ':!.cache/**'
  ':!reports/**'
)

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  set +e
  output="$(git grep -n -E "$legacy_regex" -- "${exclude_paths[@]}" 2>/dev/null)"
  rc=$?
  set -e
else
  set +e
  output="$(grep -RInE "$legacy_regex" . --exclude-dir=.git --exclude-dir=.backup --exclude-dir=.cloudflare-backups --exclude-dir=.cache --exclude-dir=reports 2>/dev/null)"
  rc=$?
  set -e
fi

if [[ "$rc" -eq 0 && -n "$output" ]]; then
  cat <<'MSG'
ERROR: legacy short Cloudflare environment variables remain in active files.
Use canonical CLOUDFLARE_* names instead.

MSG
  printf '%s\n' "$output"
  exit 1
fi

if [[ "$rc" -gt 1 ]]; then
  echo "ERROR: scan failed" >&2
  exit "$rc"
fi

echo "No legacy short Cloudflare env variables found in active files."
