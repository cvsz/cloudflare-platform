#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
trap 'echo "{\"level\":\"error\",\"script\":\"security-scan\",\"line\":$LINENO}"' ERR

: "${TRIVY_SEVERITY:=CRITICAL,HIGH}"
: "${GRYPE_FAIL_ON:=critical}"

trivy fs --config security/trivy.yml .
semgrep --config security/semgrep.yml .
gitleaks detect --config security/gitleaks.toml --source . --redact
syft . -o spdx-json > artifacts.sbom.spdx.json
grype sbom:artifacts.sbom.spdx.json --fail-on "$GRYPE_FAIL_ON"
