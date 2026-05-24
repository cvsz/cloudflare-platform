# ZeaZ Loading Worker

Bilingual Thai + English loading page for `www.zeaz.dev`, designed for Cloudflare Workers under the `cvsz/zeaz-platform` control plane.

## Files

```text
workers/zeaz-loading/
├── wrangler.toml
└── src/index.js

scripts/cloudflare/install-zeaz-loading-local.sh
```

## One-click local install

From the repository root:

```bash
bash scripts/cloudflare/install-zeaz-loading-local.sh
```

This generates or updates:

- `workers/zeaz-loading/wrangler.toml`
- `workers/zeaz-loading/src/index.js`

## Local preview

```bash
bash scripts/cloudflare/install-zeaz-loading-local.sh --preview
```

Open:

```text
http://127.0.0.1:8787
http://127.0.0.1:8787/healthz
```

## Deploy to Cloudflare

```bash
bash scripts/cloudflare/install-zeaz-loading-local.sh --deploy
```

Default route:

```text
www.zeaz.dev/*
```

## Custom options

```bash
bash scripts/cloudflare/install-zeaz-loading-local.sh \
  --brand "ZeaZ" \
  --app-url "https://app.zeaz.dev" \
  --route "www.zeaz.dev/*" \
  --zone "zeaz.dev"
```

Environment overrides are also supported:

```bash
BRAND_NAME="ZeaZ" \
APP_URL="https://app.zeaz.dev" \
ROUTE_PATTERN="www.zeaz.dev/*" \
ZONE_NAME="zeaz.dev" \
bash scripts/cloudflare/install-zeaz-loading-local.sh --deploy
```

## Health check

```bash
curl https://www.zeaz.dev/healthz
```

Expected JSON shape:

```json
{
  "ok": true,
  "service": "zeaz-loading",
  "language": "th-en"
}
```

## Notes

- The page uses no external font or asset dependency.
- Security headers are set directly by the Worker.
- Cache is disabled so the loading page updates immediately after deploy.
- The route is scoped to `www.zeaz.dev/*` so it does not collide with `app.zeaz.dev`, `auth.zeaz.dev`, `studio.zeaz.dev`, or other platform subdomains.
