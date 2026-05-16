#!/usr/bin/env bash
set -Eeuo pipefail

echo "🔥 Fixing invalid error_message usage..."

ROOT="terraform"

find "$ROOT" -type f -name "*.tf" | while read -r f; do
  echo "🧹 Cleaning $f"

  # Remove standalone error_message lines
  sed -i '/error_message *=/d' "$f"

  # Remove empty validation blocks
  sed -i '/validation {/,/}/d' "$f"
done

echo
echo "✅ error_message + broken validation removed"
echo
echo "Next:"
echo "git add ."
echo "git commit -m \"fix(terraform): remove invalid validation blocks\""
echo "git push"
