#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

cloudflare_api_check() {
  local token="$1"
  curl -sS --fail-with-body \
    -H "Authorization: Bearer ${token}" \
    -H 'Content-Type: application/json' \
    https://api.cloudflare.com/client/v4/user/tokens/verify
}
