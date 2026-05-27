#!/usr/bin/env bash
set -Eeuo pipefail

log(){ printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
warn(){ log "WARN: $*" >&2; }

has_variable(){
  local file="$1" name="$2"
  [[ -f "$file" ]] && grep -Eq "^[[:space:]]*variable[[:space:]]+\"${name}\"" "$file"
}

append_variable(){
  local file="$1" name="$2" body="$3"
  if has_variable "$file" "$name"; then
    log "skip existing variable ${name} in ${file}"
    return 0
  fi
  printf '\n%s\n' "$body" >> "$file"
  log "added variable ${name} to ${file}"
}

log "Adding missing Terraform variables idempotently"

for env in dev staging prod; do
  file="terraform/environments/$env/variables.tf"
  if [[ ! -f "$file" ]]; then
    warn "missing $file; skipped"
    continue
  fi

  append_variable "$file" enable_foundation 'variable "enable_foundation" {
  type    = bool
  default = true
}'

  append_variable "$file" enable_zero_trust 'variable "enable_zero_trust" {
  type    = bool
  default = true
}'

  append_variable "$file" enable_networking 'variable "enable_networking" {
  type    = bool
  default = true
}'

  append_variable "$file" enable_workers_ai 'variable "enable_workers_ai" {
  type    = bool
  default = false
}'

  append_variable "$file" enable_monitoring_security 'variable "enable_monitoring_security" {
  type    = bool
  default = true
}'

  append_variable "$file" cloudflare_plan_tier 'variable "cloudflare_plan_tier" {
  type    = string
  default = "Free"

  validation {
    condition     = contains(["Free", "Pro", "Business", "Enterprise"], var.cloudflare_plan_tier)
    error_message = "cloudflare_plan_tier must be Free, Pro, Business, or Enterprise."
  }
}'

done

cat <<'NEXT'

Done.

Next checks:
  terraform -chdir=terraform/environments/dev fmt
  terraform -chdir=terraform/environments/dev validate
  terraform -chdir=terraform/environments/prod fmt
  terraform -chdir=terraform/environments/prod validate
NEXT
