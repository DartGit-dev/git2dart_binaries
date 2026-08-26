# First-run onboarding: All-branch CI with main-only publication

## Purpose

Verify the CI policy after implementation without manually invoking a publisher
or inspecting publication secrets.

## Validation matrix

1. Push a documentation/test-only change to a new feature branch. Confirm build
   and test jobs start and `publish_package` is skipped.
2. Push to a non-main maintenance branch. Confirm the same validation outcome.
3. Open/update a pull request targeting main. Confirm PR validation runs and
   `publish_package` is skipped.
4. For an authorized main push, confirm `publish_package` becomes eligible only
   after every `needs` job plus platform proof, inventory, OpenSSL provenance,
   size, and dry-run checks pass.
5. Inspect job results in all four cases. Only the main-push case may expose the
   publisher step or publication credential.

## Expected failure signals

- A feature or maintenance branch does not start the workflow.
- A PR/non-main run enters `publish_package`.
- The condition uses a partial branch value instead of `refs/heads/main`.
- A main push bypasses an existing release gate.
- PR inspection-artifact behavior vanishes without an explicit decision.
