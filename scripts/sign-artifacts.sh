#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
trap 'echo "{\"level\":\"error\",\"script\":\"sign-artifacts\",\"line\":$LINENO}"' ERR

artifact="${1:-artifacts.sbom.spdx.json}"
: "${COSIGN_OPTIONAL:=true}"

if [[ -n "${COSIGN_KEY:-}" ]]; then
  cosign sign-blob --yes --key "${COSIGN_KEY}" "${artifact}"
elif [[ "${COSIGN_EXPERIMENTAL:-0}" == "1" ]]; then
  cosign sign-blob --yes "${artifact}"
elif [[ "${COSIGN_OPTIONAL}" == "true" ]]; then
  echo "cosign signing skipped (optional mode)"
else
  echo "cosign keyless/keyed config required" >&2
  exit 1
fi
