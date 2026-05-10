#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

source secrets/cloudflare.env

readonly REPO="cvsz/cloudflare-platform"

sync_secret() {
  local key="$1"
  local value="$2"

  gh secret set \
    "${key}" \
    --repo "${REPO}" \
    --body "${value}"
}

sync_secret "CF_ACCOUNT_ID" "${CF_ACCOUNT_ID}"
sync_secret "CF_ZONE_ID" "${CF_ZONE_ID}"
sync_secret "CF_DNS_TOKEN" "${CF_DNS_TOKEN}"
sync_secret "CF_ZT_TOKEN" "${CF_ZT_TOKEN}"
sync_secret "CF_WORKERS_TOKEN" "${CF_WORKERS_TOKEN}"
sync_secret "CF_WAF_TOKEN" "${CF_WAF_TOKEN}"
sync_secret "CF_TUNNEL_TOKEN" "${CF_TUNNEL_TOKEN}"
sync_secret "CF_R2_TOKEN" "${CF_R2_TOKEN}"

printf '\nGitHub secrets synced.\n'
