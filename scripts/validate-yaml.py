#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except Exception as exc:
    print(f"ERROR: PyYAML is required: {exc}")
    sys.exit(1)

ROOT = Path(".")
SKIP_PARTS = {
    ".git",
    ".backup",
    ".cloudflare-backups",
    ".terraform",
    ".venv",
    "node_modules",
    "dist",
    "build",
    "coverage",
}


def should_skip(path: Path) -> bool:
    return any(part in SKIP_PARTS for part in path.parts)


files = []
for pattern in ("*.yml", "*.yaml"):
    for path in ROOT.rglob(pattern):
        if not should_skip(path):
            files.append(path)

failed = []
for path in sorted(set(files)):
    try:
        yaml.safe_load(path.read_text(encoding="utf-8"))
    except Exception as exc:
        failed.append((path, exc))

if failed:
    for path, exc in failed:
        print(f"INVALID: {path}: {exc}")
    sys.exit(1)

print(f"Validated {len(set(files))} YAML files")
