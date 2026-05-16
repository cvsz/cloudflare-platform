#!/usr/bin/env bash
set -Eeuo pipefail

echo "🧹 Fixing broken variables.tf files..."

find terraform -type f -name "variables.tf" | while read -r f; do
  echo "🔧 Rebuilding $f"

  cat > "$f" <<EOT
variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_bootstrap_token" {
  type = string
}
EOT

done

echo "✅ variables.tf rebuilt"
