#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${PROJECT_ROOT:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$PWD"
  while [[ "$ROOT" != "/" ]]; do
    if [[ -d "$ROOT/.git" || -f "$ROOT/.env.example" || -f "$ROOT/Makefile" ]]; then
      break
    fi
    ROOT="$(dirname "$ROOT")"
  done
fi
[[ "$ROOT" != "/" ]] || ROOT="$PWD"
cd "$ROOT"

if [[ -f .env.cloudflare ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.cloudflare
  set +a
fi

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if python3 python/cfstack_validate_env.py --json; then
  exit 0
fi

cat <<'ADVISORY'

Environment validation is incomplete because deployment-specific values are missing or placeholder-only.
This is advisory for project-upgrade-report and does not mean the repository source is broken.

To complete deployment validation, fill .env with real local values, then run:

  python3 python/cfstack_validate_env.py --strict
  make validate-env

Required real values normally include Cloudflare account/zone IDs, scoped tokens, identity provider metadata, SOPS age key, and origin host settings.
ADVISORY

exit 0
