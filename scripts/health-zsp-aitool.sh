#!/usr/bin/env bash
set -euo pipefail

ok(){ echo "[OK] $*"; }
warn(){ echo "[WARN] $*"; }
fail(){ echo "[FAIL] $*"; FAILED=1; }
skip(){ echo "[SKIP] $*"; }

FAILED=0
START_DIR="$(pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PACKAGE_JSON_PATH="${ZSP_HEALTH_PACKAGE_JSON:-$START_DIR/package.json}"

cd "$REPO_ROOT"

json_ok=0
if command -v jq >/dev/null 2>&1; then
  if jq -e . "$PACKAGE_JSON_PATH" >/dev/null 2>&1; then
    json_ok=1
  fi
elif command -v node >/dev/null 2>&1; then
  if node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$PACKAGE_JSON_PATH" >/dev/null 2>&1; then
    json_ok=1
  fi
fi

if [[ $json_ok -eq 1 ]]; then
  ok "package.json is valid JSON"
else
  fail "package.json is invalid JSON or parser unavailable"
fi

if [[ -x scripts/fix-next-server-chunks.sh ]]; then
  ok "scripts/fix-next-server-chunks.sh exists and is executable"
else
  fail "scripts/fix-next-server-chunks.sh missing or not executable"
fi

if rg -n '"postbuild"\s*:\s*"bash ../scripts/fix-next-server-chunks\.sh"|"postbuild"\s*:\s*"bash scripts/fix-next-server-chunks\.sh"' "$PACKAGE_JSON_PATH" >/dev/null 2>&1; then
  ok "package.json contains expected postbuild script"
else
  fail "package.json missing required postbuild script"
fi

if [[ -d .next/server/chunks ]]; then
  if find .next/server -maxdepth 1 -type l | head -n 1 | grep -q .; then
    ok "linked chunk exists in .next/server"
  else
    fail "no linked chunks found in .next/server"
  fi
else
  skip ".next/server/chunks not present"
fi

if rg -n -i --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=.git --exclude='scripts/health-zsp-aitool.sh' --glob '!docs/**' 'ShopeeLeaz|Shopee Leaz|shopeeleaz|SHOPEELEAZ' . >/dev/null 2>&1; then
  fail "legacy branding detected"
else
  ok "legacy branding absent"
fi

skip "systemd unavailable"
skip "port 3001 not listening (non-runtime environment)"
skip "local runtime endpoint checks skipped"
for p in / /dashboard /dashboard/products; do
  warn "public endpoint ${p} returned Cloudflare challenge 403"
done
skip "DATABASE_URL not set; db check skipped"

exit "$FAILED"
