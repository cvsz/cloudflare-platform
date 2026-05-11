#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/logging.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/env.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/cloudflare.sh"

OFFLINE=false
API_CHECK=false
JSON=false
STRICT=false

while (($#)); do
  case "$1" in
    --offline) OFFLINE=true ;;
    --api-check) API_CHECK=true ;;
    --json) JSON=true ;;
    --strict) STRICT=true ;;
    *) error "unknown argument: $1"; exit 2 ;;
  esac
  shift
done

load_dotenv_if_present

args=()
$JSON && args+=(--json)
$STRICT && args+=(--strict)
python3 "${ROOT_DIR}/python/cfstack_validate_env.py" "${args[@]}"

if $OFFLINE; then
  info "offline mode: skipped Cloudflare API verification"
  exit 0
fi

if $API_CHECK; then
  tokens=(CF_API_TOKEN CF_DNS_TOKEN CF_WORKERS_TOKEN CF_ZT_TOKEN CF_WAF_TOKEN CF_TUNNEL_TOKEN CF_R2_TOKEN)
  for t in "${tokens[@]}"; do
    cloudflare_api_check "${!t}" >/dev/null
    info "token verified: ${t}"
  done
fi
