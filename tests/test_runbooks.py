from pathlib import Path

RUNBOOKS = [
    "tunnel-outage.md",
    "dns-hijacking.md",
    "jwt-compromise.md",
    "token-leakage.md",
    "waf-bypass.md",
    "saml-compromise.md",
    "ddos.md",
    "worker-deployment-failure.md",
    "certificate-expiration.md",
    "scim-failure.md",
]

REQUIRED_HEADERS = [
    "## Severity matrix",
    "## Rollback",
    "## Forensic collection",
    "## Recovery validation",
    "## Postmortem template",
]


def test_runbook_files_exist() -> None:
    for runbook in RUNBOOKS:
        assert (Path("docs/runbooks") / runbook).exists()


def test_runbooks_have_required_sections() -> None:
    for runbook in RUNBOOKS:
        content = (Path("docs/runbooks") / runbook).read_text(encoding="utf-8")
        for header in REQUIRED_HEADERS:
            assert header in content
