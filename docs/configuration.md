# Configuration and Validation (F1)

Phase F1 validates required runtime context before any provisioning.

## Modes
- `--offline`: local validation only, no network calls.
- `--api-check`: verify each Cloudflare token with `/user/tokens/verify`.
- `--json`: machine-readable output.
- `--strict`: non-zero exit when validation fails.

## Required Variables
See `.env.example` for full required variable set and accepted values.

## Usage
```bash
bash scripts/validate.sh --offline --strict
bash scripts/validate.sh --api-check --strict
bash scripts/validate.sh --offline --json
```
