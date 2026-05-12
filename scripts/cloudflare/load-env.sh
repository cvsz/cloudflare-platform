#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

log(){ printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
warn(){ log "WARN: $*" >&2; }
die(){ log "ERROR: $*" >&2; exit 1; }

find_root(){
  local d="${PROJECT_ROOT:-${GITHUB_WORKSPACE:-${PWD}}}"

  while [[ "$d" != "/" ]]; do
    if [[ -d "$d/.git" ]] || [[ -f "$d/.env.example" ]] || [[ -d "$d/terraform" ]] || [[ -f "$d/README.md" ]]; then
      printf '%s\n' "$d"
      return 0
    fi
    d="$(dirname "$d")"
  done

  printf '%s\n' "${GITHUB_WORKSPACE:-${PWD}}"
}

PROJECT_ROOT="$(find_root)"
ENV_FILE="${ENV_FILE:-$PROJECT_ROOT/.env}"
TOKEN_ENV_FILE="${TOKEN_ENV_FILE:-$PROJECT_ROOT/.env.cloudflare}"
STRICT_ENV="${STRICT_ENV:-true}"

load_file(){
  local file="$1"
  [[ -f "$file" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  source "$file"
  set +a
  log "loaded env file: $file"
}

# Runtime-injected GitHub Actions secrets have highest priority. Capture them before sourcing files.
declare -A runtime_values=()
for key in CF_ACCOUNT_ID CF_ZONE_ID CF_API_TOKEN CF_DNS_TOKEN CF_ZT_TOKEN CF_WORKERS_TOKEN CF_WAF_TOKEN CF_TUNNEL_TOKEN CF_R2_TOKEN CF_AUDIT_TOKEN CF_AI_GATEWAY_TOKEN CF_AI_GATEWAY_SLUG; do
  if [[ -n "${!key:-}" ]]; then
    runtime_values[$key]="${!key}"
  fi
done

load_file "$TOKEN_ENV_FILE"
load_file "$ENV_FILE"

for key in "${!runtime_values[@]}"; do
  export "$key=${runtime_values[$key]}"
done

: "${CF_AI_GATEWAY_SLUG:=zeaz}"
export CF_AI_GATEWAY_SLUG

required_vars=(
  CF_ACCOUNT_ID
  CF_ZONE_ID
  CF_API_TOKEN
  CF_DNS_TOKEN
  CF_ZT_TOKEN
  CF_WORKERS_TOKEN
  CF_WAF_TOKEN
  CF_TUNNEL_TOKEN
  CF_R2_TOKEN
)

missing=0
for key in "${required_vars[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    warn "missing environment variable: $key"
    missing=$((missing + 1))
  fi
done

if [[ "$missing" -gt 0 ]]; then
  if [[ "$STRICT_ENV" == "true" ]]; then
    die "$missing required environment variable(s) missing. Configure GitHub Actions secrets or provide .env/.env.cloudflare."
  fi
  warn "$missing required environment variable(s) missing; continuing because STRICT_ENV=false"
fi

if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    printf 'PROJECT_ROOT=%s\n' "$PROJECT_ROOT"
    printf 'ENV_FILE=%s\n' "$ENV_FILE"
    printf 'TOKEN_ENV_FILE=%s\n' "$TOKEN_ENV_FILE"
    printf 'CF_AI_GATEWAY_SLUG=%s\n' "$CF_AI_GATEWAY_SLUG"
  } >> "$GITHUB_ENV"
fi

log "environment loaded successfully"
