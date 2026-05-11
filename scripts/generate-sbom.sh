#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
trap 'echo "{\"level\":\"error\",\"script\":\"generate-sbom\",\"line\":$LINENO}"' ERR

out_file="${1:-artifacts.sbom.spdx.json}"
syft . -o "spdx-json=${out_file}"
echo "SBOM written to ${out_file}"
