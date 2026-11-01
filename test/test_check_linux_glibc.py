"""Behavioral tests for the Linux release glibc compatibility check."""
import importlib.util
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SCRIPT = Path(__file__).resolve().parents[1] / ".github/scripts/check_linux_glibc.py"
SPEC = importlib.util.spec_from_file_location("check_linux_glibc", SCRIPT)
glibc = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(glibc)


def version_info(*names):
    entries = "\n".join(
        f"  0x0010:   Name: {name}  Flags: none  Version: 2" for name in names
    )
    return (
        "Version symbols section '.gnu.version' contains 2 entries:\n"
        "  000: 1 (*global*)  2 (GLIBC_2.38)\n"
        "Version needs section '.gnu.version_r' contains 1 entry:\n"
        f"  0x0000: Version: 1  File: libc.so.6  Cnt: {len(names)}\n{entries}\n"
    )


class GlibcCompatibilityTest(unittest.TestCase):
    def test_reads_required_versions_not_version_symbol_display(self):
        self.assertEqual(
            glibc.required_glibc_versions(version_info("GLIBC_2.2.5", "GLIBC_2.35.0")),
            [(2, 2, 5), (2, 35)],
        )

    def test_rejects_missing_or_unknown_requirements(self):
        for output in (
            "No version information found",
            version_info(),
            version_info("GLIBC_PRIVATE"),
            version_info("GLIBC_ABI_DT_RELR"),
        ):
            with self.subTest(output=output), self.assertRaises(ValueError):
                glibc.required_glibc_versions(output)

    def test_compares_versions_numerically_and_checks_each_library(self):
        with tempfile.TemporaryDirectory() as directory:
            first, second = (
                Path(directory) / name for name in ("libgit2.so", "libssh2.so")
            )
            first.touch()
            second.touch()
            for too_new in ("2.38", "2.100"):
                with self.subTest(too_new=too_new):
                    outputs = [
                        version_info("GLIBC_2.35"),
                        version_info(f"GLIBC_{too_new}"),
                    ]
                    results = [
                        subprocess.CompletedProcess([], 0, output) for output in outputs
                    ]
                    with mock.patch.object(glibc.subprocess, "run", side_effect=results):
                        self.assertEqual(glibc.check_library(first), (2, 35))
                        with self.assertRaisesRegex(ValueError, f"GLIBC_{too_new}"):
                            glibc.check_library(second)

    def test_cli_fails_if_second_library_is_incompatible(self):
        with mock.patch.object(sys, "argv", [str(SCRIPT), "libgit2.so", "libssh2.so"]):
            with mock.patch.object(
                glibc, "check_library", side_effect=[(2, 35), ValueError("GLIBC_2.38")]
            ), mock.patch("sys.stdout"), mock.patch("sys.stderr"):
                self.assertEqual(glibc.main(), 1)

    def test_rejects_missing_library_and_readelf_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            library = Path(directory) / "libgit2.so"
            with self.assertRaisesRegex(ValueError, "missing library"):
                glibc.check_library(library)
            library.touch()
            with mock.patch.object(
                glibc.subprocess,
                "run",
                side_effect=subprocess.CalledProcessError(1, "readelf"),
            ):
                with self.assertRaises(subprocess.CalledProcessError):
                    glibc.check_library(library)

    @unittest.skipUnless(
        sys.platform.startswith("linux") and shutil.which("clang") and shutil.which("readelf"),
        "Linux clang and readelf required",
    )
    def test_real_elf_version_requirements(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            provider = root / "provider.c"
            consumer = root / "consumer.c"
            version_map = root / "versions.map"
            provider.write_text("int fixture(void) { return 1; }\n")
            consumer.write_text(
                "extern int fixture(void); int use_fixture(void) { return fixture(); }\n"
            )
            for version, accepted in (("2.35", True), ("2.38", False)):
                with self.subTest(version=version):
                    version_map.write_text(f"GLIBC_{version} {{ global: fixture; }};\n")
                    library = root / f"libprovider-{version}.so"
                    binary = root / f"consumer-{version}.so"
                    subprocess.run(
                        [
                            "clang", "-shared", "-fPIC", "-nostdlib",
                            f"-Wl,--version-script={version_map}", str(provider),
                            "-o", str(library),
                        ],
                        check=True,
                        capture_output=True,
                    )
                    subprocess.run(
                        [
                            "clang", "-shared", "-fPIC", "-nostdlib",
                            str(consumer), str(library), "-o", str(binary),
                        ],
                        check=True,
                        capture_output=True,
                    )
                    if accepted:
                        self.assertEqual(glibc.check_library(binary), (2, 35))
                    else:
                        with self.assertRaisesRegex(ValueError, "GLIBC_2.38"):
                            glibc.check_library(binary)


if __name__ == "__main__":
    unittest.main()
