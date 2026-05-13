# SBOM and Vulnerability Validation

- `generate-sbom.sh` uses Syft to build SPDX JSON SBOM.
- `security-scan.sh` uses Trivy, Grype, Semgrep, and Gitleaks.
- Critical findings fail pipelines by default.
