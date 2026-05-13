#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

find_root(){
  local d="${PROJECT_ROOT:-${PWD}}"
  while [[ "$d" != "/" ]]; do
    if [[ -d "$d/.git" ]] || [[ -d "$d/terraform" ]] || [[ -f "$d/.env.example" ]] || [[ -f "$d/README.md" ]]; then
      printf '%s\n' "$d"
      return 0
    fi
    d="$(dirname "$d")"
  done
  printf '%s\n' "${PROJECT_ROOT:-${PWD}}"
}

ROOT="$(find_root)"
ENV_FILE="${ENV_FILE:-$ROOT/.env}"
TOKEN_ENV_FILE="${TOKEN_ENV_FILE:-$ROOT/.env.cloudflare}"

load_file(){
  local file="$1"
  [[ -f "$file" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  source "$file"
  set +a
}

load_file "$TOKEN_ENV_FILE"
load_file "$ENV_FILE"

export TF_VAR_cf_dns_token="${TF_VAR_cf_dns_token:-${CF_DNS_TOKEN:-}}"
export TF_VAR_cf_zone_id="${TF_VAR_cf_zone_id:-${CF_ZONE_ID:-}}"
export TF_VAR_cf_waf_token="${TF_VAR_cf_waf_token:-${CF_WAF_TOKEN:-}}"
export TF_VAR_cf_account_id="${TF_VAR_cf_account_id:-${CF_ACCOUNT_ID:-}}"
export TF_VAR_domain="${TF_VAR_domain:-${PRIMARY_DOMAIN:-zeaz.dev}}"
export TF_VAR_plan_tier="${TF_VAR_plan_tier:-${CLOUDFLARE_PLAN_TIER:-Free}}"
export TF_VAR_environment="${TF_VAR_environment:-${ENVIRONMENT:-prod}}"
export TF_VAR_identity_provider_type="${TF_VAR_identity_provider_type:-${IDENTITY_PROVIDER_TYPE:-saml}}"
export TF_VAR_identity_provider_metadata_url="${TF_VAR_identity_provider_metadata_url:-${IDENTITY_PROVIDER_METADATA_URL:-}}"
export TF_VAR_tunnel_secret="${TF_VAR_tunnel_secret:-${TUNNEL_SECRET:-dGVzdC10dW5uZWwtc2VjcmV0LWRldGVybWluaXN0aWM=}}"
export TF_VAR_enable_waf="${TF_VAR_enable_waf:-${ENABLE_WAF:-false}}"

case "${TF_VAR_enable_waf}" in
  true|false) ;;
  TRUE|True) export TF_VAR_enable_waf=true ;;
  FALSE|False) export TF_VAR_enable_waf=false ;;
  *)
    printf 'ERROR: ENABLE_WAF/TF_VAR_enable_waf must be true or false, got: %s\n' "${TF_VAR_enable_waf}" >&2
    exit 1
    ;;
esac

exec "$@"
