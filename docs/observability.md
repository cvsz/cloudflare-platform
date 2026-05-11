# Observability

This stack uses Prometheus, Grafana, Loki, Alertmanager, and OpenTelemetry Collector.

## Alert routing

Alert destination webhooks are loaded from secret files mounted at runtime:

- `/etc/alertmanager/secrets/default_webhook_url`
- `/etc/alertmanager/secrets/security_webhook_url`

No webhook URL is stored in git.

## Dashboards

- auth failures
- WAF blocks
- bot attacks
- tunnel health
- JWT failures
- API latency
- Workers failures
- certificate expiration
- DNS propagation
