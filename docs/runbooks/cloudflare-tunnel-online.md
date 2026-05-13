# Cloudflare Tunnel Online Runbook

This runbook documents the recovery path used to bring `zveo.zeaz.dev` online through Cloudflare Tunnel.

## Known-good baseline

- Public hostname: `zveo.zeaz.dev`
- Expected public status: `HTTP/2 200`
- Active tunnel target: `ef0355dd-8e90-45ed-a222-b5053794ed20.cfargotunnel.com`
- Sample origin service: `http://localhost:8080`
- Terraform drift: none

## Symptoms and causes

### HTTP 530

Cloudflare can resolve/proxy the hostname, but the DNS record points to a tunnel with no healthy connector.

Common cause:

- DNS CNAME points to one tunnel ID, while `cloudflared` is connected to another tunnel ID.

Check:

```bash
dig +short CNAME zveo.zeaz.dev
sudo journalctl -u cloudflared -n 100 --no-pager | grep -Ei 'Starting tunnel|Registered tunnel|error'
```

The CNAME tunnel ID must match the tunnel ID in the `cloudflared` logs.

### HTTP 503

Cloudflare reaches the active tunnel, but cloudflared has no ingress rule or cannot reach the configured origin.

Confirm with logs:

```bash
sudo journalctl -u cloudflared -n 100 --no-pager | grep -Ei 'No ingress|503|localhost|service|error'
```

Known log:

```text
No ingress rules were defined in provided config (if any) nor from the cli, cloudflared will return 503 for all incoming HTTP requests
```

Fix by adding a Public Hostname to the active tunnel:

```text
Hostname: zveo.zeaz.dev
Service Type: HTTP
URL: localhost:8080
```

Do not create a duplicate DNS record. Terraform owns DNS.

### HTTPS self-redirect loop

If `https://zveo.zeaz.dev/` redirects to itself repeatedly:

- Check Cloudflare SSL mode is `Full` or `Full (strict)`, not `Flexible`.
- Check Cloudflare Redirect Rules, Page Rules, and Configuration Rules.
- Check origin app/proxy trusts `X-Forwarded-Proto: https`.

## Temporary sample origin

Run this when validating tunnel connectivity:

```bash
mkdir -p /tmp/zeaz-sample-app
cat > /tmp/zeaz-sample-app/index.html <<'HTML'
<!doctype html>
<html>
  <head><title>ZEAZ Tunnel OK</title></head>
  <body>
    <h1>ZEAZ Tunnel OK</h1>
    <p>zveo.zeaz.dev is reaching localhost:8080.</p>
  </body>
</html>
HTML

python3 -m http.server 8080 --directory /tmp/zeaz-sample-app
```

In another terminal:

```bash
curl -sI http://localhost:8080 | grep -Ei 'HTTP|server'
curl -sI https://zveo.zeaz.dev/ | grep -Ei 'HTTP|location|server|cf-ray'
```

Expected:

```text
HTTP/1.0 200 OK
HTTP/2 200
server: cloudflare
```

## Terraform DNS alignment

The Terraform-managed CNAMEs should point to the active tunnel ID:

```hcl
content = "ef0355dd-8e90-45ed-a222-b5053794ed20.cfargotunnel.com"
```

Verify state:

```bash
terraform -chdir=terraform state show 'cloudflare_record.tunnel_cname["zveo.zeaz.dev"]' | grep -E 'name|hostname|content|value'
```

Expected:

```text
content  = "ef0355dd-8e90-45ed-a222-b5053794ed20.cfargotunnel.com"
hostname = "zveo.zeaz.dev"
name     = "zveo.zeaz.dev"
```

## Cloudflared service repair

Use the repair helper:

```bash
bash scripts/cloudflare/repair-cloudflared-service.sh
```

The token must be a real tunnel connector token from:

```text
Cloudflare Zero Trust -> Networks -> Tunnels -> selected tunnel -> Configure -> Install and run connector
```

A Cloudflare API token is not a valid `cloudflared service install` token.

## Final validation

```bash
make validate-agent
make drift
curl -sI https://zveo.zeaz.dev/ | grep -Ei 'HTTP|server|cf-ray'
git status
```

Expected:

```text
CI validation complete.
No drift detected.
HTTP/2 200
nothing to commit, working tree clean
```
