# Disaster Recovery

Run `scripts/backup.sh` daily and verify with monthly restore drills.

## Recovery objectives

- RPO: 24h
- RTO: 2h

## Validation

- Check Terraform/OpenTofu plans are clean post-restore.
- Run `pytest -q tests/test_runbooks.py` after updates.
