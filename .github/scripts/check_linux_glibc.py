#!/usr/bin/env python3
"""Reject Linux release libraries requiring glibc newer than Ubuntu 22.04."""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

MAX_GLIBC = (2, 35)


def required_glibc_versions(output: str) -> list[tuple[int, ...]]:
    section = re.search(
        r"(?ms)^[ \t]*Version needs section[^\n]*\n(.*?)(?=^[ \t]*Version \w+ section|\Z)",
        output,
    )
    if not section:
        raise ValueError("no ELF version requirements found")
    names = re.findall(r"\bName:\s*(GLIBC_\S+)", section.group(1))
    if not names:
        raise ValueError("no glibc version requirements found")

    versions = []
    for name in names:
        if not re.fullmatch(r"GLIBC_\d+(?:\.\d+)+", name):
            raise ValueError(f"unsupported glibc version requirement: {name}")
        parts = [int(part) for part in name.removeprefix("GLIBC_").split(".")]
        while len(parts) > 1 and parts[-1] == 0:
            parts.pop()
        versions.append(tuple(parts))
    return versions


def check_library(path: Path) -> tuple[int, ...]:
    if not path.is_file():
        raise ValueError(f"missing library: {path}")
    result = subprocess.run(
        ["readelf", "--version-info", "--wide", str(path)],
        check=True,
        capture_output=True,
        text=True,
        env={**os.environ, "LC_ALL": "C"},
    )
    highest = max(required_glibc_versions(result.stdout))
    if highest > MAX_GLIBC:
        required = ".".join(map(str, highest))
        raise ValueError(f"{path} requires GLIBC_{required}, newer than GLIBC_2.35")
    return highest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("libraries", nargs="+", type=Path)
    args = parser.parse_args()
    try:
        for library in args.libraries:
            highest = ".".join(map(str, check_library(library)))
            print(f"{library}: highest glibc requirement is GLIBC_{highest}")
    except (OSError, subprocess.CalledProcessError, ValueError) as error:
        print(f"Linux glibc compatibility check failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
