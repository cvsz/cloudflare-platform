#!/usr/bin/env bash
set -Eeuo pipefail

echo "🔄 Syncing with remote..."

BRANCH=$(git rev-parse --abbrev-ref HEAD)

git pull --rebase origin "$BRANCH"

echo "🚀 Pushing..."

git push origin "$BRANCH"

echo "✅ Done"
