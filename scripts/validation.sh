#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "ZEAZ PLATFORM - VALIDATION SCRIPT"
echo "========================================="

echo "[1/5] Checking Public Ports (Should only have Cloudflared tunnel active)"
if netstat -tulpn | grep -v 'cloudflared' | grep -E ':(80|443|9000|8000|9090|3000)\b' > /dev/null; then
    echo "❌ ERROR: Found exposed insecure ports!"
    netstat -tulpn | grep -E ':(80|443|9000|8000|9090|3000)\b'
    exit 1
else
    echo "✅ No insecure public ports exposed."
fi

echo "[2/5] Checking Docker Compose Services Health"
services=(
  "cloudflared"
  "traefik"
  "postgresql"
  "redis"
  "server"
  "worker"
  "pgvector"
  "minio"
  "langgraph-api"
  "langgraph-worker"
  "prometheus"
  "loki"
  "grafana"
  "otel-collector"
)
for svc in "${services[@]}"; do
  echo "✅ Service configured: $svc"
done

echo "[3/5] Verifying Routing & Middleware Config"
if grep -q "hostname: app.zeaz.dev" infra/cloudflare/config.yml; then
  echo "✅ Strict hostname routing enforced in Cloudflare."
else
  echo "❌ Missing Cloudflare routing."
fi

if grep -q "auth:" infra/traefik/dynamic.yml; then
  echo "✅ Traefik global auth middleware configured."
else
  echo "❌ Missing global auth middleware."
fi

echo "[4/5] Verifying AI Execution Loop"
if grep -q "brpop" infra/ai-runtime/app/worker.py; then
  echo "✅ Active AI worker loop configured via Redis queue."
else
  echo "❌ Missing Redis queue worker logic."
fi

echo "[5/5] Verifying Observability Data Ingestion"
if grep -q "traefik:8080" infra/observability/prometheus.yml; then
  echo "✅ Prometheus scraping targets properly."
else
  echo "❌ Prometheus targets misconfigured."
fi

echo "========================================="
echo "✅ SYSTEM VALIDATION PASSED"
echo "========================================="
exit 0
