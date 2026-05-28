#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ASSIGN_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
SECRET_HINT_RE = re.compile(r"(TOKEN|SECRET|KEY|PASSWORD)", re.I)
DEFAULT_FILES = [Path(".env.example")]
OPTIONAL_EMPTY_DROP = {
    "CLOUDFLARE_AUDIT_TOKEN",
    "CLOUDFLARE_AI_GATEWAY_TOKEN",
}


def mask_value(key: str, value: str) -> str:
    if not SECRET_HINT_RE.search(key):
        return value
    if not value:
        return ""
    return "<redacted>"


def validate_file(path: Path) -> list[str]:
    errors: list[str] = []
    if not path.exists():
        return errors

    seen: dict[str, int] = {}
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        match = ASSIGN_RE.match(line)
        if not match:
            continue

        key, raw_value = match.group(1), match.group(2)
        value = raw_value.strip()

        if key in seen:
            errors.append(f"{path}:{lineno}: duplicate env key {key}; first seen line {seen[key]}")
        else:
            seen[key] = lineno

        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            display = mask_value(key, value)
            errors.append(f"{path}:{lineno}: quoted env value for {key}: {display}; use {key}={value[1:-1]}")

        if key in OPTIONAL_EMPTY_DROP and value in {"", '""', "''"}:
            errors.append(f"{path}:{lineno}: optional empty {key} should be omitted")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate generated env file formatting.")
    parser.add_argument("files", nargs="*", type=Path, default=DEFAULT_FILES)
    args = parser.parse_args()

    errors: list[str] = []
    for path in args.files:
        errors.extend(validate_file(path))

    if errors:
        print("Env formatting validation failed:", file=sys.stderr)
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    checked = ", ".join(str(p) for p in args.files if p.exists()) or "<none>"
    print(f"Env formatting validation passed: {checked}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
