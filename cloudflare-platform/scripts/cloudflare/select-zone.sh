#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

: "${CF_EMAIL:?Missing CF_EMAIL}"
: "${CF_GLOBAL_API_KEY:?Missing CF_GLOBAL_API_KEY}"

readonly TARGET_DOMAIN="zeaz.dev"

response="$(
  curl -sS \
    "https://api.cloudflare.com/client/v4/zones?page=1&per_page=100" \
    -H "X-Auth-Email: ${CF_EMAIL}" \
    -H "X-Auth-Key: ${CF_GLOBAL_API_KEY}"
)"

success="$(echo "${response}" | jq -r '.success')"

if [[ "${success}" != "true" ]]; then
  echo "${response}" | jq
  exit 1
fi

CF_ZONE_ID="$(
  echo "${response}" \
    | jq -r \
      --arg DOMAIN "${TARGET_DOMAIN}" '
        .result[]
        | select(.name == $DOMAIN)
        | .id
      '
)"

if [[ -z "${CF_ZONE_ID}" || "${CF_ZONE_ID}" == "null" ]]; then
  echo "Zone not found"
  exit 1
fi

printf '\nZone: %s\n' "${TARGET_DOMAIN}"
printf 'Zone ID: %s\n' "${CF_ZONE_ID}"
