# ZVEO Integration

ZVEO integrates into the Zeaz Cloudflare Platform as the AI content/video/social automation layer.

## Public routes

| Hostname | Purpose | Local origin |
|---|---|---|
| `zveo.zeaz.dev` | Next.js dashboard | `http://127.0.0.1:3002` |
| `api.zveo.zeaz.dev` | API gateway | `http://127.0.0.1:8090` |

## Services

- `zveo-web`
- `zveo-api`
- `zveo-render-worker`

## Stack

- Next.js dashboard
- API gateway
- BullMQ queues
- Redis
- PostgreSQL
- Cloudflare Tunnel
- Cloudflare Zero Trust

## Operational checks

```bash
zveo-health
systemctl status zveo-api
systemctl status zveo-web
```

## Cloudflare integration

Ingress routing is defined under:

```text
tunnels/cloudflared/zeaz-platform.yml
```

Terraform DNS records provision:

- `zveo.zeaz.dev`
- `api.zveo.zeaz.dev`

## Notes

Cloudflare Tunnel is token-based in production.
Cloudflare Zero Trust Public Hostnames are the source of truth.
