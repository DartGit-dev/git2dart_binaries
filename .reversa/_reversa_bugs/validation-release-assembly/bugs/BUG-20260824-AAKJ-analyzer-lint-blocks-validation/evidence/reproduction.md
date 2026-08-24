# Reproduction capsule

- Base commit: `b9a2c3e1da53129ba14547849aa2abd6dbd4f7b3`
- Branch: `1.12.2`
- Environment: Windows, Flutter SDK available in the project shell
- Command: `flutter analyze`
- Result: exit code 1, 1/1 failures
- Classification: deterministic

Observed diagnostics:

1. `test/opts_bindings_integration_test.dart:2:1`: `directives_ordering`.
2. `test/workflow_trigger_policy_test.dart:29:16`: `use_raw_strings`.

The command reports these as `info`, but its nonzero exit status blocks the validation stage.
