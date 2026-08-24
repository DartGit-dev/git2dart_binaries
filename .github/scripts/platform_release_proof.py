#!/usr/bin/env python3
"""Fail-closed evidence for an assembled, platform-native release payload."""
from __future__ import annotations

import argparse
import ctypes
import hashlib
import json
import os
import plistlib
import re
import subprocess
import sys
from pathlib import Path

SCHEMA = "platform-release-proof/v1"
FAILURE_CODES = {
    "invalid-schema", "invalid-path", "missing-payload", "unexpected-payload",
    "loader-failed", "linkage-failed", "version-unreadable", "version-mismatch",
    "unavailable", "unsafe-field",
}
EXPECTED = {
    "linux": ("libgit2.so", "libssh2.so"),
    "macos": ("libgit2.dylib",),
    "windows": ("libgit2.dll", "libssh2.dll", "libcrypto*.dll", "libssl*.dll"),
    "android": ("libgit2.so", "libssh2.so", "libcrypto.so", "libssl.so"),
    "ios": tuple(f"{name}.xcframework/Info.plist" for name in ("libcrypto", "libssl", "libssh2", "libgit2")),
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def tree_sha256(root: Path) -> str:
    digest = hashlib.sha256()
    for item in sorted(path for path in root.rglob("*") if path.is_file()):
        digest.update(item.relative_to(root).as_posix().encode("utf-8"))
        digest.update(sha256(item).encode("ascii"))
    return digest.hexdigest()


def safe_relative(value: str) -> str:
    path = Path(value)
    if path.is_absolute() or ".." in path.parts or "\\" in value:
        raise ValueError("invalid-path")
    return path.as_posix()


def inventory(root: Path, expected: tuple[str, ...]) -> tuple[list[dict], list[str], list[str]]:
    files = {item.relative_to(root).as_posix(): item for item in root.rglob("*") if item.is_file()}
    present, missing = [], []
    matched: set[str] = set()
    for pattern in expected:
        hits = sorted(name for name in files if Path(name).match(pattern))
        if not hits:
            missing.append(pattern)
        for name in hits:
            safe_relative(name)
            matched.add(name)
            item = files[name]
            present.append({"path": name, "sha256": sha256(item), "size": item.stat().st_size})
    # Payload proof only reports candidates relevant to the native contract.
    expected_roots = {pattern.split("/", 1)[0] for pattern in expected}
    unexpected = sorted(
        name for name in files
        if name.endswith((".so", ".dylib", ".dll", ".a", ".plist"))
        and name not in matched and name.split("/", 1)[0] not in expected_roots
    )
    return present, missing, unexpected


def _run(command: list[str], env: dict[str, str] | None = None) -> tuple[bool, str]:
    result = subprocess.run(command, text=True, capture_output=True, env=env, check=False)
    return result.returncode == 0, (result.stdout + result.stderr).strip()[-400:]


def linkage(root: Path, platform: str) -> tuple[bool, str]:
    if platform == "android":
        return _run(["readelf", "-d", str(root / "libgit2.so")])
    if platform == "ios":
        plist = root / "libgit2.xcframework" / "Info.plist"
        try:
            plistlib.loads(plist.read_bytes())
        except (OSError, ValueError, plistlib.InvalidFileException) as error:
            return False, f"invalid XCFramework metadata: {error}"
        libraries = list(root.glob("libgit2.xcframework/**/*.a"))
        return _run(["nm", "-gU", str(libraries[0])]) if libraries else (False, "no final static libgit2 slice")
    library = root / ("libgit2.dll" if platform == "windows" else "libgit2.dylib" if platform == "macos" else "libgit2.so")
    env = os.environ.copy()
    key = "PATH" if platform == "windows" else "DYLD_LIBRARY_PATH" if platform == "macos" else "LD_LIBRARY_PATH"
    env[key] = f"{root}{os.pathsep}{env.get(key, '')}"
    script = "import ctypes,sys; ctypes.CDLL(sys.argv[1])"
    return _run([sys.executable, "-c", script, str(library)], env)


def sanitize_diagnostic(value: str, root: Path) -> str:
    value = value.replace(str(root), "<payload>")
    return re.sub(r"(?:[A-Za-z]:)?[/\\][^\s:]+", "<path>", value)


def version_text(root: Path) -> str:
    files = root.rglob("*") if root.is_dir() else (root,)
    blobs = b"\n".join(item.read_bytes() for item in files if item.is_file() and item.stat().st_size < 128 * 1024 * 1024)
    return blobs.decode("latin1", "ignore")


def observed_version(text: str, wanted: str) -> str | None:
    if re.search(re.escape(wanted), text):
        return wanted
    fields = {
        name: re.search(rf"(?m)^{name}\s*=\s*(\d+)\s*$", text)
        for name in ("MAJOR", "MINOR", "PATCH")
    }
    assembled = ".".join(fields[name].group(1) for name in ("MAJOR", "MINOR", "PATCH") if fields[name])
    return wanted if assembled == wanted else None


def observed_versions(root: Path, expected: dict[str, str], evidence: Path | None = None) -> tuple[dict[str, dict[str, str]], list[str]]:
    text = version_text(root)
    evidence_text = version_text(evidence) if evidence and evidence.exists() else ""
    values, failures = {}, []
    for dependency, wanted in expected.items():
        observed = observed_version(text, wanted)
        source = "payload"
        if not observed:
            observed = observed_version(evidence_text, wanted)
            source = "build-input" if observed else "unavailable"
        values[dependency] = {"intended": wanted, "observed": observed or "unavailable", "comparison": "match" if observed else "unavailable", "evidence": source}
        if not observed:
            failures.append("version-unreadable")
    return values, failures


def create(args: argparse.Namespace) -> int:
    if args.platform not in EXPECTED or args.abi and not re.fullmatch(r"[A-Za-z0-9_-]+", args.abi):
        raise ValueError("invalid-path")
    root = Path(args.root).resolve()
    if not root.is_dir():
        raise ValueError("unavailable")
    present, missing, unexpected = inventory(root, EXPECTED[args.platform])
    evidence = Path(args.version_evidence).resolve() if args.version_evidence else None
    versions, failures = observed_versions(root, {"libgit2": args.libgit2, "libssh2": args.libssh2, "openssl": args.openssl}, evidence)
    linked, diagnostic = linkage(root, args.platform) if not missing else (False, "payload is incomplete")
    diagnostic = sanitize_diagnostic(diagnostic, root)
    if missing: failures.append("missing-payload")
    if unexpected: failures.append("unexpected-payload")
    if not linked: failures.append("linkage-failed" if args.platform in {"ios", "macos"} else "loader-failed")
    attestation = None
    if args.platform in {"ios", "macos"}:
        input_root = Path(args.attestation_input).resolve() if args.attestation_input else None
        toolchain_ok, toolchain = _run(["xcrun", "clang", "--version"])
        sdk_ok, sdk = _run(["xcrun", "--show-sdk-version"])
        attestation = {
            "input_sha256": tree_sha256(input_root) if input_root and input_root.is_dir() else "unavailable",
            "emitted_sha256": tree_sha256(root),
            "toolchain": toolchain if toolchain_ok else "unavailable",
            "sdk": sdk if sdk_ok else "unavailable",
            "compiled_metadata": versions,
        }
        if "unavailable" in attestation.values(): failures.append("unavailable")
    failures = sorted(set(failures))
    record = {
        "schema": SCHEMA, "candidate": args.candidate, "platform": args.platform,
        "abi": args.abi or "default", "status": "passed" if not failures else "failed",
        "inventory": {"expected": list(EXPECTED[args.platform]), "present": present, "missing": missing, "unexpected": unexpected},
        "linkage": {"result": "passed" if linked else "failed", "diagnostic": diagnostic},
        "versions": versions, "attestation": attestation, "failure_codes": failures,
    }
    output = Path(args.output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    (output / "proof.json").write_text(json.dumps(record, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    lines = [f"# Platform release proof: {args.platform}/{record['abi']}", "", f"Status: **{record['status']}**", "", "## Inventory", "", f"Missing: {', '.join(missing) or 'none'}", f"Unexpected: {', '.join(unexpected) or 'none'}", "", "## Diagnostics", "", f"Linkage: {record['linkage']['result']} — {diagnostic}", f"Failures: {', '.join(failures) or 'none'}", ""]
    (output / "proof.md").write_text("\n".join(lines), encoding="utf-8")
    return 0 if not failures else 1


def validate(args: argparse.Namespace) -> int:
    expected_scopes = {"linux/default", "macos/default", "windows/default", "ios/default", *(f"android/{abi}" for abi in ("x86_64", "arm64-v8a", "x86", "armeabi-v7a"))}
    seen: set[str] = set()
    for path in Path(args.proofs).rglob("proof.json"):
        try:
            record = json.loads(path.read_text(encoding="utf-8"))
            required = {"schema", "candidate", "platform", "abi", "status", "inventory", "linkage", "versions", "attestation", "failure_codes"}
            if set(record) != required or record["schema"] != SCHEMA:
                raise ValueError("unknown schema")
            if record["status"] != "passed" or record["failure_codes"]:
                raise ValueError("failed proof")
            scope = f"{record['platform']}/{record['abi']}"
            if scope in seen or scope not in expected_scopes:
                raise ValueError("unexpected proof scope")
            seen.add(scope)
        except (OSError, ValueError, TypeError, json.JSONDecodeError) as error:
            print(f"Platform proof rejected: {path}: {error}", file=sys.stderr)
            return 1
    missing = expected_scopes - seen
    if missing:
        print(f"Platform proof rejected: missing {sorted(missing)}", file=sys.stderr)
        return 1
    print(f"Validated {len(seen)} same-run platform proofs")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    proof = commands.add_parser("create")
    proof.add_argument("--platform", required=True, choices=EXPECTED)
    proof.add_argument("--abi")
    proof.add_argument("--root", required=True)
    proof.add_argument("--output", required=True)
    proof.add_argument("--candidate", required=True)
    proof.add_argument("--libgit2", required=True)
    proof.add_argument("--libssh2", required=True)
    proof.add_argument("--openssl", required=True)
    proof.add_argument("--version-evidence")
    proof.add_argument("--attestation-input")
    check = commands.add_parser("validate")
    check.add_argument("--proofs", required=True)
    args = parser.parse_args()
    try:
        return create(args) if args.command == "create" else validate(args)
    except (OSError, ValueError) as error:
        print(f"Platform proof rejected: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
