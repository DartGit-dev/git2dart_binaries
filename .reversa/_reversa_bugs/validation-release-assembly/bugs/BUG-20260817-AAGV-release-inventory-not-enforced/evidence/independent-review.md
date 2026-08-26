# Independent post-Gate-2 review — BUG-20260817-AAGV

Verdict: **reject**.

## Blocking findings

1. **High — producer/validator linkage incompatibility.**
   Successful Linux, Windows, and macOS `ctypes.CDLL` probes return an empty
   diagnostic, while `validate_semantics` rejects any empty passed-linkage
   diagnostic. A valid producer proof can therefore block the aggregate release
   gate. Required follow-up: emit a stable non-empty successful-linkage
   diagnostic (or permit empty diagnostics for passed linkage) and add a
   create-to-validate round-trip regression test.

2. **High — attestation semantic gap.**
   Validation currently accepts any non-empty attestation mapping. It does not
   require or validate the emitted payload digest, nor Apple input/output,
   toolchain, SDK, or compiled metadata. Required follow-up: enforce
   platform-specific required attestation fields and digest formats/identity,
   then add rejection tests for arbitrary non-empty and incomplete Apple
   attestations.

## Residual observations

- `validate --payload-root` is optional outside the production workflow.
- `fix/CHG-002.diff` is a prose summary rather than an exact applied patch.
- No hosted CI evidence exists.

The reviewer inspected the bug record, effective requirements and W002/W003,
plan, CHG artifacts, current code and tests, and Gate-1/Gate-2 evidence. The
reviewer did not modify files.
