#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${PROJECT_ROOT:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$PWD"
  while [[ "$ROOT" != "/" ]]; do
    if [[ -d "$ROOT/.git" || -f "$ROOT/.env.example" || -f "$ROOT/Makefile" ]]; then
      break
    fi
    ROOT="$(dirname "$ROOT")"
  done
fi
[[ "$ROOT" != "/" ]] || ROOT="$PWD"
cd "$ROOT"

log(){ printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
die(){ log "ERROR: $*" >&2; exit 1; }

load_env_file(){
  local file="$1"
  [[ -f "$file" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  source "$file"
  set +a
}

contains_arg(){
  local wanted="$1"
  shift
  local arg
  for arg in "$@"; do
    [[ "$arg" == "$wanted" ]] && return 0
  done
  return 1
}

value_after_arg(){
  local wanted="$1"
  shift
  local prev=""
  local arg
  for arg in "$@"; do
    if [[ "$prev" == "$wanted" ]]; then
      printf '%s' "$arg"
      return 0
    fi
    prev="$arg"
  done
  return 1
}

# Load .env first, then .env.cloudflare so generated token files can override.
load_env_file .env
load_env_file .env.cloudflare

: "${CF_AI_GATEWAY_SLUG:=zeaz}"
export CF_AI_GATEWAY_SLUG

[[ -n "${CF_ACCOUNT_ID:-}" ]] || die "CF_ACCOUNT_ID is missing. Fill it in .env before token rotation."
[[ -n "${CF_BOOTSTRAP_TOKEN:-}" ]] || die "CF_BOOTSTRAP_TOKEN is missing. Fill it in .env before token rotation."

if contains_arg --regenerate "$@"; then
  types="$(value_after_arg --types "$@" || true)"
  [[ -n "$types" ]] || die "--regenerate requires --types"
  if [[ "$types" == "all" || ",$types," == *",dns,"* ]]; then
    [[ -n "${CF_ZONE_ID:-}" ]] || die "CF_ZONE_ID is missing. DNS token creation needs the real Cloudflare zone ID; otherwise Cloudflare receives invalid resource com.cloudflare.api.account.zone."
  fi
fi

exec bash scripts/cloudflare/clean-and-regenerate-tokens.sh "$@"
