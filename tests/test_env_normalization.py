from __future__ import annotations

import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NORMALIZER = ROOT / "scripts" / "cloudflare" / "clean-env-empty-values.sh"
VALIDATOR = ROOT / "scripts" / "validate-env-files.py"


def run_cmd(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(args),
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=check,
    )


def test_clean_env_empty_values_normalizes_quotes_duplicates_and_optional_tokens(tmp_path: Path) -> None:
    env_file = tmp_path / ".env"
    env_file.write_text(
        "\n".join(
            [
                'A="1"',
                'A="2"',
                'EMPTY=""',
                'CLOUDFLARE_AUDIT_TOKEN=""',
                'CLOUDFLARE_AI_GATEWAY_TOKEN=""',
                "PLAIN=value",
                "",
            ]
        ),
        encoding="utf-8",
    )

    run_cmd("bash", str(NORMALIZER), str(env_file))

    result = env_file.read_text(encoding="utf-8").splitlines()
    assert "A=2" in result
    assert "EMPTY=" in result
    assert "PLAIN=value" in result
    assert not any(line.startswith("CLOUDFLARE_AUDIT_TOKEN=") for line in result)
    assert not any(line.startswith("CLOUDFLARE_AI_GATEWAY_TOKEN=") for line in result)
    assert not any('="' in line or "='" in line for line in result)
    assert sum(1 for line in result if line.startswith("A=")) == 1


def test_clean_env_empty_values_strips_bootstrap_token_from_env_cloudflare(tmp_path: Path) -> None:
    token_env = tmp_path / ".env.cloudflare"
    token_env.write_text(
        "\n".join(
            [
                "CLOUDFLARE_BOOTSTRAP_TOKEN=should-not-live-here",
                "CLOUDFLARE_DNS_TOKEN=scoped-token",
                "",
            ]
        ),
        encoding="utf-8",
    )

    run_cmd("bash", str(NORMALIZER), str(token_env))

    result = token_env.read_text(encoding="utf-8")
    assert "CLOUDFLARE_BOOTSTRAP_TOKEN=" not in result
    assert "CLOUDFLARE_DNS_TOKEN=scoped-token" in result


def test_validate_env_files_detects_duplicate_quoted_and_optional_empty_tokens(tmp_path: Path) -> None:
    env_file = tmp_path / ".env"
    env_file.write_text(
        "\n".join(
            [
                'A="1"',
                "A=2",
                'CLOUDFLARE_AUDIT_TOKEN=""',
                'CLOUDFLARE_AI_GATEWAY_TOKEN=""',
                'CLOUDFLARE_DNS_TOKEN="secret-value"',
                "",
            ]
        ),
        encoding="utf-8",
    )

    proc = run_cmd("python3", str(VALIDATOR), str(env_file), check=False)

    assert proc.returncode == 1
    combined = proc.stdout + proc.stderr
    assert "duplicate env key A" in combined
    assert "quoted env value for A" in combined
    assert "optional empty CLOUDFLARE_AUDIT_TOKEN should be omitted" in combined
    assert "optional empty CLOUDFLARE_AI_GATEWAY_TOKEN should be omitted" in combined
    assert "secret-value" not in combined
    assert "<redacted>" in combined
