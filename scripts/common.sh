#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_TS() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { printf '{"ts":"%s","level":"%s","script":"%s","msg":"%s"}\n' "$(LOG_TS)" "$1" "$(basename "$0")" "$2"; }
info(){ log INFO "$1"; }
warn(){ log WARN "$1"; }
err(){ log ERROR "$1"; }

cleanup(){ local rc=$?; if [ $rc -ne 0 ]; then err "failed rc=$rc"; fi; }
trap cleanup EXIT

retry() {
  local attempts=${1:-3}; shift
  local n=1
  until "$@"; do
    if [ "$n" -ge "$attempts" ]; then
      err "command failed after $attempts attempts: $*"
      return 1
    fi
    warn "retry $n/$attempts: $*"
    sleep $((n*2))
    n=$((n+1))
  done
}

require_env(){
  local miss=0
  for v in "$@"; do
    if [ -z "${!v:-}" ]; then err "missing required env var $v"; miss=1; fi
  done
  [ "$miss" -eq 0 ]
}

normalize_plan_tier(){
  local raw="${CLOUDFLARE_PLAN_TIER:-Free}"
  case "${raw,,}" in
    free) plan_tier="Free" ;;
    pro) plan_tier="Pro" ;;
    business) plan_tier="Business" ;;
    enterprise) plan_tier="Enterprise" ;;
    *) plan_tier="$raw" ;;
  esac
  export CLOUDFLARE_PLAN_TIER="$plan_tier"
}

validate_plan(){
  normalize_plan_tier
  case "$plan_tier" in Free|Pro|Business|Enterprise) ;; *) err "invalid CLOUDFLARE_PLAN_TIER=$plan_tier"; return 1;; esac
  : "${COST_LOCK:=true}"
  export COST_LOCK
  if [[ "$plan_tier" == "Free" && "$COST_LOCK" != "true" ]]; then
    warn "Free plan detected with COST_LOCK=$COST_LOCK; paid-capable workflows may not be guarded"
  fi
  info "detected plan tier $plan_tier cost_lock=$COST_LOCK"
}

validate_backend(){
  local backend="${TERRAFORM_BACKEND_TYPE:-local}"
  case "$backend" in
    local) return 0 ;;
    s3) require_env TERRAFORM_STATE_BUCKET TERRAFORM_LOCK_TABLE ;;
    *) err "invalid TERRAFORM_BACKEND_TYPE=$backend"; return 1 ;;
  esac
}

health_check(){ retry 2 terraform -chdir="$PROJECT_ROOT/terraform" fmt -check >/dev/null; }
