#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

MODE="${1:-}"
STRICT_TOOLS="${STRICT_TOOLS:-false}"
[[ "${MODE}" == "--strict-tools" ]] && STRICT_TOOLS=true

log(){ printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
warn(){ log "WARN: $*" >&2; }
die(){ log "ERROR: $*" >&2; exit 1; }
has(){ command -v "$1" >/dev/null 2>&1; }

find_root() {
  local d="${PWD}"

  while [[ "${d}" != "/" ]]; do
    if [[ -d "${d}/.git" ]] ||
       [[ -d "${d}/terraform" ]] ||
       [[ -f "${d}/.env.example" ]] ||
       [[ -f "${d}/python/cfstack_validate_env.py" ]]; then
      printf '%s\n' "${d}"
      return 0
    fi
    d="$(dirname "${d}")"
  done

  return 1
}

ROOT="${PROJECT_ROOT:-}"
if [[ -z "${ROOT}" ]]; then
  ROOT="$(find_root || true)"
fi

[[ -n "${ROOT}" && "${ROOT}" != "/" ]] || {
  warn "could not detect repo root from PWD=${PWD}"
  warn "set PROJECT_ROOT=/home/zeazdev/cloudflare-platform"
  exit 0
}

ENV_FILE="${ENV_FILE:-$ROOT/.env}"
BACKUP_DIR="$ROOT/.cloudflare-backups"

mkdir -p "${BACKUP_DIR}"

if [[ -f "${ENV_FILE}" ]]; then
  cp "${ENV_FILE}" "${BACKUP_DIR}/env.$(date -u +%Y%m%dT%H%M%SZ).bak"
  log "backup saved under ${BACKUP_DIR}"
fi

cat > "${ENV_FILE}" <<'ENV'
CF_ACCOUNT_ID=
CF_ZONE_ID=
CF_API_TOKEN=
CF_DNS_TOKEN=
CF_WORKERS_TOKEN=
CF_ZT_TOKEN=
CF_WAF_TOKEN=
CF_TUNNEL_TOKEN=
CF_R2_TOKEN=

CLOUDFLARE_PLAN_TIER=Free
IDENTITY_PROVIDER_TYPE=saml
IDENTITY_PROVIDER_VENDOR=authentik
IDENTITY_PROVIDER_METADATA_URL=https://auth.zeaz.dev/application/saml/cloudflare-zero-trust/metadata/

PRIMARY_DOMAIN=zeaz.dev
ENVIRONMENT=prod
REGION=ap-southeast-1

ORIGIN_INFRA_TYPE=vm
ORIGIN_HOSTS=app.internal,pay.internal

TERRAFORM_BACKEND_TYPE=s3
TERRAFORM_STATE_BUCKET=zeaz-dev-cloudflare-platform-tfstate
TERRAFORM_LOCK_TABLE=zeaz-dev-cloudflare-platform-tflock

SOPS_AGE_KEY=
SECRET_ROTATION_INTERVAL=30d
ENV

chmod 600 "${ENV_FILE}"
log "wrote ${ENV_FILE}"

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

if has python3 && [[ -f "$ROOT/python/cfstack_validate_env.py" ]]; then
  python3 "$ROOT/python/cfstack_validate_env.py" --strict || \
    warn "env validation failed because IDs, tokens, or SOPS_AGE_KEY are still empty"
else
  warn "python3 or validator missing; skipped env validation"
fi

if has terraform && [[ -d "$ROOT/terraform" ]]; then
  terraform -chdir="$ROOT/terraform" fmt -recursive || warn "terraform fmt failed"
  terraform -chdir="$ROOT/terraform" init -backend=false || warn "terraform init failed"
  terraform -chdir="$ROOT/terraform" validate || warn "terraform validate failed"
else
  if [[ "${STRICT_TOOLS}" == "true" ]]; then
    die "terraform is required but missing"
  fi
  warn "terraform missing or terraform/ directory not found; skipped terraform init/validate"
fi

log "environment setup complete"
