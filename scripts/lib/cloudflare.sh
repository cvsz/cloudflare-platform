#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

cloudflare_api_check() {
  local token="$1"
  local expected_permission="$2"

  curl -sS --fail-with-body \
    -H "Authorization: Bearer ${token}" \
    -H 'Content-Type: application/json' \
    https://api.cloudflare.com/client/v4/user/tokens/verify \
  | python3 - "$expected_permission" <<'PY'
import json
import sys

expected = sys.argv[1].lower()
payload = json.load(sys.stdin)
if not payload.get("success"):
    print("Cloudflare token verification failed", file=sys.stderr)
    sys.exit(1)

status = payload.get("result", {}).get("status", "").lower()
if status != "active":
    print("Cloudflare token is not active", file=sys.stderr)
    sys.exit(1)

scopes = [str(v).lower() for v in payload.get("result", {}).get("policies", [])]
if expected and scopes and expected not in " ".join(scopes):
    print(f"Token permissions may be insufficient (expected hint: {expected})", file=sys.stderr)
PY
}
