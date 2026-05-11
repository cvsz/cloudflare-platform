# Incident Runbook

## Severity matrix
- Sev1: customer-impacting outage or active compromise
- Sev2: degraded service or attempted compromise
- Sev3: contained issue with no customer impact

## Detection and triage
- Confirm indicators from monitoring and audit logs.
- Open incident channel and assign commander.

## Rollback
- Revert last known-good infrastructure/config release.
- Validate rollback with smoke checks and policy tests.

## Forensic collection
- Export Cloudflare audit logs and WAF events.
- Preserve worker logs, tunnel metrics, and IAM events.
- Hash evidence and store immutable copies.

## Recovery validation
- Confirm service SLOs recovered.
- Verify auth, JWT, WAF, and tunnel checks are green.
- Run post-recovery drift detection.

## Postmortem template
- Timeline
- Root cause
- Contributing factors
- Corrective actions
- Owners and due dates
