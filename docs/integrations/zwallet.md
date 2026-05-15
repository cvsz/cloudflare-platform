# zWallet Integration

zWallet integrates into the Zeaz Cloudflare Platform as the Web3 wallet and treasury layer.

## Public routes

| Hostname | Purpose | Local origin |
|---|---|---|
| `app.zeaz.dev` | zWallet Next.js frontend | `http://127.0.0.1:3000` |
| `admin-wallet.zeaz.dev` | zWallet admin/API runtime | `http://127.0.0.1:8081` |

## Services

- `zwallet-web`
- `zwallet`
- `zwallet-transfer-worker`

## Stack

- Next.js frontend
- wallet-engine
- admin-wallet API
- Redis queue
- PostgreSQL
- transfer worker
- nonce manager
- pending transaction tracker
- signing audit infrastructure
- Cloudflare Tunnel
- Cloudflare Zero Trust

## Operational checks

```bash
zeaz-health
systemctl status zwallet
systemctl status zwallet-web
systemctl status zwallet-transfer-worker
curl -s https://admin-wallet.zeaz.dev/healthz
```

## Cloudflare integration

Ingress routing is defined under:

```text
tunnels/cloudflared/zeaz-platform.yml
```

Terraform DNS records provision:

- `app.zeaz.dev`
- `admin-wallet.zeaz.dev`

## Notes

zWallet is an application layer under the Cloudflare Platform control plane. Cloudflare handles public HTTPS and routes traffic to local origins through Tunnel.
