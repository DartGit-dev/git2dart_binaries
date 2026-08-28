import 'dart:io';

import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  final facts = WorkflowPolicyFacts.fromFile(
    '.github/workflows/build_package.yml',
  );

  test(
    'validates pushes from every branch while retaining main pull requests',
    () {
      expect(
        facts.eventAccepted(event: 'push', ref: 'refs/heads/feature'),
        isTrue,
      );
      expect(
        facts.eventAccepted(event: 'pull_request', ref: 'refs/heads/main'),
        isTrue,
      );
      expect(
        facts.eventAccepted(event: 'pull_request', ref: 'refs/heads/feature'),
        isFalse,
      );
    },
  );

  test(
    'keeps package validation available while guarding only publication',
    () {
      expect(
        facts.validationReachable(
          event: 'pull_request',
          ref: 'refs/heads/main',
        ),
        isTrue,
      );
      expect(
        facts.publicationReachable(
          event: 'pull_request',
          ref: 'refs/heads/main',
        ),
        isFalse,
      );
      expect(
        facts.publicationReachable(event: 'push', ref: 'refs/heads/main'),
        isTrue,
      );
    },
  );

  test('skips package build for a docs-tagged push', () {
    const docsCommit = 'docs: refresh API reference [docs]';
    expect(
      facts.validationReachable(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: docsCommit,
      ),
      isFalse,
    );
    final acknowledgement = facts.jobs['docs_commit_acknowledgement']!;
    expect(
      acknowledgement.condition.evaluate(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: docsCommit,
      ),
      isTrue,
    );
    expect(
      acknowledgement.condition.evaluate(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: 'docs: refresh API reference',
      ),
      isFalse,
    );
  });

  test('cold boots the cached Android AVD before integration tests', () {
    final workflow =
        File('.github/workflows/build_package.yml').readAsStringSync();

    expect(
      workflow,
      contains(
        'emulator-options: -no-window -gpu swiftshader_indirect '
        '-delay-adb -no-snapshot-load -no-snapshot-save -noaudio '
        '-no-boot-anim -camera-back none',
      ),
    );
  });

  test('resets the iOS simulator before retrying a timed-out test', () {
    final workflow =
        File('.github/workflows/build_package.yml').readAsStringSync();

    expect(
      workflow,
      contains(r'xcrun simctl terminate "$device_id" "$bundle_id" || true'),
    );
    expect(workflow, contains(r'xcrun simctl shutdown "$device_id" || true'));
    expect(workflow, contains(r'xcrun simctl erase "$device_id"'));
    expect(workflow, contains(r'xcrun simctl boot "$device_id"'));
  });
}
