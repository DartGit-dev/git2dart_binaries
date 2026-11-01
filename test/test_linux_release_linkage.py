"""Verify the Linux proof loads the bundled sidecar by its package filename."""
import importlib.util
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / ".github/scripts/platform_release_proof.py"
SPEC = importlib.util.spec_from_file_location("platform_release_proof", SCRIPT)
proof = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(proof)


@unittest.skipUnless(
    sys.platform.startswith("linux") and shutil.which("clang"),
    "Linux and clang are required",
)
class LinuxReleaseLinkageTest(unittest.TestCase):
    def test_loads_bundled_sidecar_when_soname_file_is_absent(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sidecar_source = root / "sidecar.c"
            library_source = root / "library.c"
            sidecar = root / "libssh2.so"
            library = root / "libgit2.so"
            sidecar_source.write_text("int git2dart_proof_only(void) { return 42; }\n")
            library_source.write_text(
                "extern int git2dart_proof_only(void); "
                "int test_library(void) { return git2dart_proof_only(); }\n"
            )
            subprocess.run(
                [
                    "clang", "-shared", "-fPIC", "-Wl,-soname,libssh2.so.1",
                    str(sidecar_source), "-o", str(sidecar),
                ],
                check=True,
                capture_output=True,
            )
            subprocess.run(
                [
                    "clang", "-shared", "-fPIC", str(library_source),
                    str(sidecar), "-o", str(library),
                ],
                check=True,
                capture_output=True,
            )

            self.assertFalse((root / "libssh2.so.1").exists())
            ok, diagnostic = proof.linkage(root, "linux")
            self.assertTrue(ok, diagnostic)

            sidecar.unlink()
            ok, _ = proof.linkage(root, "linux")
            self.assertFalse(ok)


if __name__ == "__main__":
    unittest.main()
