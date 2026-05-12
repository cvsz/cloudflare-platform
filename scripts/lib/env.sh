#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

readonly REQUIRED_ENV_VARS=(
  CF_ACCOUNT_ID CF_ZONE_ID CF_API_TOKEN CF_DNS_TOKEN CF_WORKERS_TOKEN CF_ZT_TOKEN CF_WAF_TOKEN CF_TUNNEL_TOKEN CF_R2_TOKEN
  IDENTITY_PROVIDER_TYPE IDENTITY_PROVIDER_VENDOR IDENTITY_PROVIDER_METADATA_URL
  ENVIRONMENT REGION PRIMARY_DOMAIN ORIGIN_INFRA_TYPE ORIGIN_HOSTS
  TERRAFORM_BACKEND_TYPE TERRAFORM_STATE_BUCKET TERRAFORM_LOCK_TABLE
  SOPS_AGE_KEY SECRET_ROTATION_INTERVAL CLOUDFLARE_PLAN_TIER
)

load_dotenv_if_present() {
  local env_path="${1:-.env}"
  if [[ -f "${env_path}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${env_path}"
    set +a
  fi
}

require_env_presence() {
  local missing=0
  local var
  for var in "${REQUIRED_ENV_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
      missing=$((missing + 1))
      printf 'ERROR: %s: missing\n' "${var}" >&2
    fi
  done
  return "${missing}"
}
