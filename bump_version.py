#!/usr/bin/env python3
"""Bump patch version in VERSION + version.py (used by CI on every push)."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VERSION_FILE = ROOT / "VERSION"
VERSION_PY = ROOT / "version.py"


def read_version() -> str:
    text = VERSION_FILE.read_text(encoding="utf-8").strip()
    if not text:
        return "0.0.0"
    return text.splitlines()[0].strip().lstrip("vV")


def bump_patch(version: str) -> str:
    parts = [int(p) if p.isdigit() else 0 for p in version.split(".")]
    while len(parts) < 3:
        parts.append(0)
    parts[2] += 1
    return ".".join(str(p) for p in parts[:3])


def write_version(version: str) -> None:
    VERSION_FILE.write_text(version + "\n", encoding="utf-8")
    py = VERSION_PY.read_text(encoding="utf-8")
    updated, count = re.subn(
        r'^APP_VERSION\s*=\s*["\'][^"\']*["\']',
        f'APP_VERSION = "{version}"',
        py,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise SystemExit("Could not update APP_VERSION in version.py")
    VERSION_PY.write_text(updated, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--set",
        metavar="X.Y.Z",
        help="Set an exact version instead of bumping the patch",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the next version without writing files",
    )
    args = parser.parse_args()

    current = read_version()
    new = args.set.strip().lstrip("vV") if args.set else bump_patch(current)
    if args.dry_run:
        print(new)
        return 0
    write_version(new)
    print(new)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
