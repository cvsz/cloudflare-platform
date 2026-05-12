#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKFLOW_DIR="${ROOT_DIR}/.github/workflows"

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--help]

Validate GitHub Actions workflow policy requirements offline.
USAGE
}

cleanup() {
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    printf '{"level":"ERROR","script":"%s","msg":"workflow policy validation failed","exit_code":%d}\n' "$(basename "$0")" "$rc" >&2
  fi
}
trap cleanup EXIT

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -d "${WORKFLOW_DIR}" ]]; then
  printf '{"level":"ERROR","script":"%s","msg":"workflow directory not found","path":"%s"}\n' "$(basename "$0")" "${WORKFLOW_DIR}" >&2
  exit 2
fi

fail_count=0

while IFS= read -r workflow_file; do
  [[ -z "$workflow_file" ]] && continue

  if ! rg -q '^permissions:' "$workflow_file"; then
    printf '{"level":"ERROR","file":"%s","msg":"missing top-level permissions"}\n' "${workflow_file#${ROOT_DIR}/}" >&2
    fail_count=$((fail_count + 1))
  fi

  if ! rg -q 'timeout-minutes:' "$workflow_file"; then
    printf '{"level":"ERROR","file":"%s","msg":"missing job timeout-minutes"}\n' "${workflow_file#${ROOT_DIR}/}" >&2
    fail_count=$((fail_count + 1))
  fi

  if rg -q '^\s*push:' "$workflow_file" && rg -q 'apply|destroy' "$workflow_file"; then
    printf '{"level":"ERROR","file":"%s","msg":"mutating workflow must not run on push"}\n' "${workflow_file#${ROOT_DIR}/}" >&2
    fail_count=$((fail_count + 1))
  fi

done < <(find "$WORKFLOW_DIR" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)

if [[ $fail_count -gt 0 ]]; then
  printf '{"level":"ERROR","msg":"workflow policy violations","count":%d}\n' "$fail_count" >&2
  exit 1
fi

printf '{"level":"INFO","msg":"workflow policy validation passed"}\n'
