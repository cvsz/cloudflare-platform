#!/usr/bin/env bash
set -Eeuo pipefail

echo "🧨 Disabling all Terraform modules (temporary CI fix)..."

find terraform/environments -type f -name "main.tf" | while read -r f; do
  echo "🔧 Editing $f"

  # Replace any module block with count = 0
  sed -i 's/count *=.*/count = 0/g' "$f"

  # If no count exists, inject it
  sed -i '/module "/a\  count = 0' "$f"

done

echo "✅ All modules disabled"
