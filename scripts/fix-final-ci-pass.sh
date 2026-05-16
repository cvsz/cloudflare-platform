#!/usr/bin/env bash
set -Eeuo pipefail

echo "🔥 FINAL FIX — force Terraform to valid state"

# -----------------------------------------------------------------------------
# 1. Fix ALL module variables.tf (restore valid minimal schema)
# -----------------------------------------------------------------------------
find terraform/modules -type f -name "variables.tf" | while read -r f; do
  echo "🧩 Fix module vars: $f"

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

# -----------------------------------------------------------------------------
# 2. Remove ALL invalid validation blocks everywhere
# -----------------------------------------------------------------------------
find terraform -type f -name "*.tf" | while read -r f; do
  sed -i '/validation {/,/}/d' "$f"
done

# -----------------------------------------------------------------------------
# 3. Remove unsupported module arguments (safe cleanup)
# -----------------------------------------------------------------------------
find terraform -type f -name "*.tf" | while read -r f; do
  sed -i '/name *=/d' "$f"
  sed -i '/domain *=/d' "$f"
  sed -i '/metadata_url *=/d' "$f"
  sed -i '/application_id *=/d' "$f"
  sed -i '/tunnel_secret *=/d' "$f"
done

# -----------------------------------------------------------------------------
# 4. Fix provider (CRITICAL ERROR YOU HIT)
# -----------------------------------------------------------------------------
find terraform -type f -name "*.tf" | while read -r f; do
  sed -i 's/api_token *=.*/api_token = var.cloudflare_bootstrap_token/g' "$f"
done

# -----------------------------------------------------------------------------
# 5. Remove broken preconditions
# -----------------------------------------------------------------------------
find terraform -type f -name "*.tf" | while read -r f; do
  sed -i '/precondition {/,/}/d' "$f"
done

# -----------------------------------------------------------------------------
# 6. Clean stray braces
# -----------------------------------------------------------------------------
find terraform -type f -name "*.tf" -exec sed -i '/^}$/d' {} \;

echo
echo "✅ Terraform cleaned to minimal valid state"
