#!/usr/bin/env python3
"""Create and validate deterministic manifests for native CI caches."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path


SCHEMA = "native-v1"


def metadata(args: argparse.Namespace) -> dict[str, str]:
    return {
        "schema": SCHEMA,
        "platform": args.platform,
        "abi": args.abi,
        "libgit2": args.libgit2,
        "libssh2": args.libssh2,
        "openssl": args.openssl,
        "toolchain": args.toolchain,
    }


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def exported_files(root: Path) -> dict[str, dict[str, int | str]]:
    files: dict[str, dict[str, int | str]] = {}
    for path in sorted(item for item in root.rglob("*") if item.is_file()):
        relative = path.relative_to(root).as_posix()
        files[relative] = {"sha256": digest(path), "size": path.stat().st_size}
    if not files:
        raise ValueError(f"No exported files found below {root}")
    return files


def create(args: argparse.Namespace) -> int:
    root = Path(args.export_root).resolve()
    manifest = metadata(args)
    manifest["files"] = exported_files(root)
    output = Path(args.manifest)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Created {output} with {len(manifest['files'])} exported files")
    return 0


def validate(args: argparse.Namespace) -> int:
    manifest_path = Path(args.manifest)
    root = Path(args.export_root).resolve()
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        expected = metadata(args)
        for key, value in expected.items():
            if manifest.get(key) != value:
                raise ValueError(f"Manifest {key} mismatch")

        recorded = manifest.get("files")
        if not isinstance(recorded, dict) or not recorded:
            raise ValueError("Manifest contains no exported files")

        current = exported_files(root)
        if set(current) != set(recorded):
            raise ValueError("Exported file list mismatch")
        for relative, details in current.items():
            if details != recorded[relative]:
                raise ValueError(f"Checksum or size mismatch: {relative}")
    except (OSError, ValueError, json.JSONDecodeError, KeyError, TypeError) as error:
        print(f"Native cache validation failed: {error}", file=sys.stderr)
        return 1

    print(f"Validated {manifest_path} with {len(recorded)} exported files")
    return 0


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    result.add_argument("command", choices=("create", "validate"))
    result.add_argument("--manifest", required=True)
    result.add_argument("--export-root", required=True)
    result.add_argument("--platform", required=True)
    result.add_argument("--abi", required=True)
    result.add_argument("--libgit2", required=True)
    result.add_argument("--libssh2", required=True)
    result.add_argument("--openssl", required=True)
    result.add_argument("--toolchain", required=True)
    return result


def main() -> int:
    args = parser().parse_args()
    return create(args) if args.command == "create" else validate(args)


if __name__ == "__main__":
    raise SystemExit(main())
