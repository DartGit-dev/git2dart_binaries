# Fix verification — BUG-20260817-AAGV

## Implemented change

The publish job now validates a fail-closed inventory before the package-size
and dry-run gates. It requires generated bindings, Linux sidecars, macOS and
Windows native files, the four Android ABI library sets, and four iOS
XCFrameworks.

## Regression evidence

On 2026-08-23, the following command passed:

```text
flutter test -j 1 test/release_inventory_workflow_test.dart
```

## Boundary

The local test validates workflow structure. A hosted release assembly must
still prove that downloaded CI artifacts satisfy the inventory.
